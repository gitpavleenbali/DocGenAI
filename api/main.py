# FastAPI Backend for DocGenAI Workshop - Full RAG Implementation

from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import os
import logging
import asyncio
import json
import uuid
from datetime import datetime
from typing import List, Dict, Any
import numpy as np
from io import BytesIO

# Azure SDK imports
from azure.storage.blob import BlobServiceClient
from azure.search.documents import SearchClient
from azure.search.documents.indexes import SearchIndexClient
from azure.search.documents.models import VectorizedQuery
from azure.cosmos import CosmosClient
from azure.core.credentials import AzureKeyCredential
from azure.identity import DefaultAzureCredential

# OpenAI and document processing
from openai import AzureOpenAI
import PyPDF2
import tiktoken

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI
app = FastAPI(
    title="DocGenAI API - Full RAG Implementation",
    description="AI-powered document analysis API with complete RAG pipeline",
    version="2.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Azure Configuration
class AzureConfig:
    def __init__(self):
        # Azure OpenAI
        self.openai_endpoint = os.getenv("AZURE_OPENAI_ENDPOINT", "https://cs-openai-varcvenlme53e.openai.azure.com/")
        self.openai_key = os.getenv("AZURE_OPENAI_KEY", "your-openai-key-here")
        self.openai_api_version = "2024-08-01-preview"
        self.chat_deployment = "gpt-4o-mini"
        self.embedding_deployment = "text-embedding-3-small"
        
        # Azure Search
        self.search_endpoint = os.getenv("AZURE_SEARCH_ENDPOINT", "https://srch-dev-varcvenlme53e.search.windows.net")
        self.search_key = os.getenv("AZURE_SEARCH_KEY", "your-search-key-here")
        self.search_index = "documents-index"
        
        # Azure Storage
        self.storage_account = os.getenv("AZURE_STORAGE_ACCOUNT", "stdevvarcvenlme53e000")
        self.storage_key = os.getenv("AZURE_STORAGE_KEY", "your-storage-key-here")
        self.storage_connection = f"DefaultEndpointsProtocol=https;AccountName={self.storage_account};AccountKey={self.storage_key};EndpointSuffix=core.windows.net"
        self.storage_container = "documents"
        
        # Azure Cosmos DB
        self.cosmos_endpoint = os.getenv("AZURE_COSMOS_ENDPOINT", "https://cosmos-dev-varcvenlme53e.documents.azure.com:443/")
        self.cosmos_key = os.getenv("AZURE_COSMOS_KEY", "your-cosmos-key-here")
        self.cosmos_database = "docgen"
        self.cosmos_container = "documents"

# Initialize Azure services
config = AzureConfig()

# Azure OpenAI client
openai_client = AzureOpenAI(
    azure_endpoint=config.openai_endpoint,
    api_key=config.openai_key,
    api_version=config.openai_api_version
)

# Azure Storage client with error handling
blob_service_client = None
try:
    # Try connection string first
    blob_service_client = BlobServiceClient.from_connection_string(config.storage_connection)
    logger.info("Blob service client initialized with connection string")
except Exception as connection_error:
    logger.warning(f"Failed to initialize blob client with connection string: {connection_error}")
    try:
        # Fallback to account URL and key
        blob_service_client = BlobServiceClient(
            account_url=f"https://{config.storage_account}.blob.core.windows.net",
            credential=config.storage_key
        )
        logger.info("Blob service client initialized with account URL and key")
    except Exception as url_error:
        logger.error(f"Failed to initialize blob client with account URL: {url_error}")
        try:
            # Try managed identity as last resort
            credential = DefaultAzureCredential()
            blob_service_client = BlobServiceClient(
                account_url=f"https://{config.storage_account}.blob.core.windows.net",
                credential=credential
            )
            logger.info("Blob service client initialized with managed identity")
        except Exception as identity_error:
            logger.error(f"Failed to initialize blob client with managed identity: {identity_error}")
            blob_service_client = None

# Azure Search clients
search_credential = AzureKeyCredential(config.search_key)
search_client = SearchClient(
    endpoint=config.search_endpoint,
    index_name=config.search_index,
    credential=search_credential
)
search_index_client = SearchIndexClient(
    endpoint=config.search_endpoint,
    credential=search_credential
)

# Azure Cosmos DB client - Using managed identity
# Initialize Cosmos DB client with comprehensive error handling
cosmos_client = None
try:
    # Try managed identity first
    credential = DefaultAzureCredential()
    cosmos_client = CosmosClient(config.cosmos_endpoint, credential)
    logger.info("Cosmos DB client initialized with managed identity")
except Exception as managed_identity_error:
    logger.warning(f"Failed to use managed identity for Cosmos DB: {managed_identity_error}")
    try:
        # Fallback to API key
        cosmos_client = CosmosClient(config.cosmos_endpoint, config.cosmos_key)
        logger.info("Cosmos DB client initialized with API key")
    except Exception as api_key_error:
        logger.error(f"Failed to initialize Cosmos DB client with API key: {api_key_error}")
        logger.info("API will run with limited functionality (no document metadata storage)")
        cosmos_client = None

# Tokenizer for chunking
tokenizer = tiktoken.get_encoding("cl100k_base")

class DocumentProcessor:
    def __init__(self):
        self.chunk_size = 1000  # tokens
        self.chunk_overlap = 200  # tokens
    
    def extract_text_from_pdf(self, pdf_content: bytes) -> str:
        """Extract text from PDF content"""
        try:
            pdf_reader = PyPDF2.PdfReader(BytesIO(pdf_content))
            text = ""
            for page in pdf_reader.pages:
                text += page.extract_text() + "\n"
            return text
        except Exception as e:
            logger.error(f"Error extracting text from PDF: {e}")
            raise HTTPException(status_code=400, detail="Failed to extract text from PDF")
    
    def chunk_text(self, text: str) -> List[Dict[str, Any]]:
        """Split text into overlapping chunks"""
        tokens = tokenizer.encode(text)
        chunks = []
        
        start = 0
        chunk_id = 0
        
        while start < len(tokens):
            end = min(start + self.chunk_size, len(tokens))
            chunk_tokens = tokens[start:end]
            chunk_text = tokenizer.decode(chunk_tokens)
            
            chunks.append({
                "id": chunk_id,
                "text": chunk_text,
                "token_count": len(chunk_tokens),
                "start_position": start,
                "end_position": end
            })
            
            chunk_id += 1
            start += self.chunk_size - self.chunk_overlap
        
        return chunks
    
    async def get_embeddings(self, texts: List[str]) -> List[List[float]]:
        """Generate embeddings for text chunks"""
        try:
            response = openai_client.embeddings.create(
                model=config.embedding_deployment,
                input=texts
            )
            return [embedding.embedding for embedding in response.data]
        except Exception as e:
            logger.error(f"Error generating embeddings: {e}")
            raise HTTPException(status_code=500, detail="Failed to generate embeddings")

# Initialize document processor
doc_processor = DocumentProcessor()

async def ensure_search_index():
    """Ensure the search index exists with proper schema"""
    try:
        from azure.search.documents.indexes.models import (
            SearchIndex, SearchField, SearchFieldDataType, SimpleField, 
            SearchableField, VectorSearch, VectorSearchProfile, 
            HnswAlgorithmConfiguration
        )
        
        # Define search index schema
        fields = [
            SimpleField(name="id", type=SearchFieldDataType.String, key=True),
            SimpleField(name="document_id", type=SearchFieldDataType.String),
            SimpleField(name="document_name", type=SearchFieldDataType.String),
            SearchableField(name="content", type=SearchFieldDataType.String),
            SimpleField(name="chunk_id", type=SearchFieldDataType.Int32),
            SimpleField(name="token_count", type=SearchFieldDataType.Int32),
            SimpleField(name="upload_date", type=SearchFieldDataType.DateTimeOffset),
            SearchField(
                name="content_vector",
                type=SearchFieldDataType.Collection(SearchFieldDataType.Single),
                searchable=True,
                vector_search_dimensions=1536,
                vector_search_profile_name="default-vector-profile"
            )
        ]
        
        # Vector search configuration
        vector_search = VectorSearch(
            profiles=[
                VectorSearchProfile(
                    name="default-vector-profile",
                    algorithm_configuration_name="hnsw-config"
                )
            ],
            algorithms=[
                HnswAlgorithmConfiguration(name="hnsw-config")
            ]
        )
        
        # Create index
        index = SearchIndex(
            name=config.search_index,
            fields=fields,
            vector_search=vector_search
        )
        
        try:
            search_index_client.create_index(index)
            logger.info(f"Created search index: {config.search_index}")
        except Exception as e:
            if "already exists" in str(e).lower():
                logger.info(f"Search index {config.search_index} already exists")
            else:
                logger.error(f"Error creating search index: {e}")
                
    except Exception as e:
        logger.error(f"Error setting up search index: {e}")

async def ensure_cosmos_database():
    """Ensure Cosmos DB database and container exist"""
    if not cosmos_client:
        logger.warning("Cosmos DB client not available, skipping database setup")
        return
        
    try:
        # Create database
        try:
            database = cosmos_client.create_database(id=config.cosmos_database)
            logger.info(f"Created Cosmos database: {config.cosmos_database}")
        except Exception as e:
            if "already exists" in str(e).lower():
                database = cosmos_client.get_database_client(config.cosmos_database)
                logger.info(f"Cosmos database {config.cosmos_database} already exists")
            else:
                raise e
        
        # Create container
        try:
            container = database.create_container(
                id=config.cosmos_container,
                partition_key="/document_id"
            )
            logger.info(f"Created Cosmos container: {config.cosmos_container}")
        except Exception as e:
            if "already exists" in str(e).lower():
                logger.info(f"Cosmos container {config.cosmos_container} already exists")
            else:
                raise e
                
    except Exception as e:
        logger.error(f"Error setting up Cosmos DB: {e}")

# Initialize Azure resources on startup
@app.on_event("startup")
async def startup_event():
    """Initialize Azure resources on application startup"""
    logger.info("Initializing Azure resources...")
    await ensure_search_index()
    await ensure_cosmos_database()
    logger.info("Azure resources initialized successfully!")

@app.get("/")
async def root():
    """Root endpoint for basic connectivity test"""
    return {
        "message": "DocGenAI API with Full RAG Implementation is running!",
        "version": "2.0.0",
        "features": ["Document Upload", "Text Extraction", "Vector Search", "RAG Chat"],
        "workshop": "Azure AI Foundry & Copilot Studio"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring"""
    return {
        "status": "healthy",
        "service": "docgenai-api",
        "version": "2.0.0",
        "rag_enabled": True
    }

@app.post("/documents/upload")
async def upload_document(file: UploadFile = File(...)):
    """Upload and process a PDF document with full RAG pipeline"""
    try:
        # Validate file type
        if not file.filename or not file.filename.endswith('.pdf'):
            raise HTTPException(status_code=400, detail="Only PDF files are supported")
        
        # Generate unique document ID
        document_id = str(uuid.uuid4())
        upload_date = datetime.utcnow()
        
        # Read file content
        file_content = await file.read()
        
        # Extract text from PDF
        logger.info(f"Extracting text from PDF: {file.filename}")
        text_content = doc_processor.extract_text_from_pdf(file_content)
        
        if not text_content.strip():
            raise HTTPException(status_code=400, detail="No text content found in PDF")
        
        # Upload file to Azure Blob Storage (if available)
        if blob_service_client:
            logger.info(f"Uploading file to blob storage: {file.filename}")
            blob_name = f"{document_id}/{file.filename}"
            blob_client = blob_service_client.get_blob_client(
                container=config.storage_container, 
                blob=blob_name
            )
            
            try:
                blob_client.upload_blob(file_content, overwrite=True)
                logger.info(f"Successfully uploaded to blob storage: {blob_name}")
            except Exception as e:
                # Create container if it doesn't exist
                try:
                    container_client = blob_service_client.get_container_client(config.storage_container)
                    container_client.create_container()
                    blob_client.upload_blob(file_content, overwrite=True)
                    logger.info(f"Created container and uploaded to blob storage: {blob_name}")
                except Exception as container_error:
                    logger.error(f"Failed to upload to blob storage: {container_error}")
                    # Continue without blob storage
        else:
            logger.warning("Blob storage client not available, skipping file upload to storage")
        
        # Chunk the text
        logger.info("Chunking text content")
        chunks = doc_processor.chunk_text(text_content)
        
        # Generate embeddings for chunks
        logger.info("Generating embeddings for text chunks")
        chunk_texts = [chunk["text"] for chunk in chunks]
        embeddings = await doc_processor.get_embeddings(chunk_texts)
        
        # Store document metadata in Cosmos DB (optional - fallback if fails)
        if cosmos_client:
            logger.info("Storing document metadata in Cosmos DB")
            document_metadata = {
                "id": document_id,
                "document_id": document_id,
                "filename": file.filename,
                "upload_date": upload_date.isoformat(),
                "total_chunks": len(chunks),
                "total_tokens": sum(chunk["token_count"] for chunk in chunks),
                "content_preview": text_content[:500]
            }
            
            # Add blob path only if blob storage is available
            if blob_service_client:
                document_metadata["blob_path"] = f"{document_id}/{file.filename}"
            
            try:
                database = cosmos_client.get_database_client(config.cosmos_database)
                container = database.get_container_client(config.cosmos_container)
                container.create_item(document_metadata)
                logger.info("Successfully stored metadata in Cosmos DB")
            except Exception as e:
                logger.warning(f"Failed to store in Cosmos DB (will continue): {e}")
                # Continue with search index even if Cosmos fails
        else:
            logger.warning("Cosmos DB client not available, skipping metadata storage")
        
        # Index chunks in Azure AI Search
        logger.info("Indexing chunks in Azure AI Search")
        search_documents = []
        
        for i, (chunk, embedding) in enumerate(zip(chunks, embeddings)):
            search_doc = {
                "id": f"{document_id}_chunk_{i}",
                "document_id": document_id,
                "document_name": file.filename,
                "content": chunk["text"],
                "chunk_id": i,
                "token_count": chunk["token_count"],
                "upload_date": upload_date,
                "content_vector": embedding
            }
            search_documents.append(search_doc)
        
        # Upload to search index in batches
        batch_size = 100
        for i in range(0, len(search_documents), batch_size):
            batch = search_documents[i:i + batch_size]
            try:
                result = search_client.upload_documents(documents=batch)
                logger.info(f"Uploaded batch {i//batch_size + 1} to search index")
            except Exception as e:
                logger.error(f"Error uploading to search index: {e}")
                # Try to continue with other batches
        
        logger.info(f"Successfully processed document: {file.filename}")
        
        return {
            "document_id": document_id,
            "filename": file.filename,
            "total_chunks": len(chunks),
            "total_tokens": sum(chunk["token_count"] for chunk in chunks),
            "upload_date": upload_date.isoformat(),
            "status": "processed_successfully",
            "message": "Document uploaded and processed successfully with full RAG pipeline"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error processing document upload: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to process document: {str(e)}")

@app.post("/chat")
async def chat_with_documents(message: dict):
    """Chat with uploaded documents using RAG"""
    try:
        user_message = message.get("message", "")
        
        if not user_message:
            raise HTTPException(status_code=400, detail="Message is required")
        
        # Generate embedding for user query
        logger.info(f"Processing chat query: {user_message}")
        query_embeddings = await doc_processor.get_embeddings([user_message])
        query_vector = query_embeddings[0]
        
        # Search for relevant document chunks
        vector_query = VectorizedQuery(
            vector=query_vector,
            k_nearest_neighbors=5,
            fields="content_vector"
        )
        
        search_results = search_client.search(
            search_text=user_message,
            vector_queries=[vector_query],
            select=["document_name", "content", "chunk_id", "document_id"],
            top=5
        )
        
        # Collect relevant chunks
        relevant_chunks = []
        sources = []
        
        for result in search_results:
            relevant_chunks.append(result["content"])
            sources.append({
                "document_name": result["document_name"],
                "chunk_id": result["chunk_id"],
                "document_id": result["document_id"],
                "score": result.get("@search.score", 0)
            })
        
        if not relevant_chunks:
            return {
                "response": "I couldn't find any relevant information in the uploaded documents to answer your question. Please make sure you have uploaded documents and try asking about their content.",
                "sources": [],
                "status": "no_relevant_content"
            }
        
        # Create context from relevant chunks
        context = "\n\n".join(relevant_chunks)
        
        # Generate response using Azure OpenAI
        system_prompt = """You are a helpful AI assistant that answers questions based on document content provided to you. 
        Use only the information from the provided documents to answer questions. 
        If the information isn't in the documents, say so clearly.
        Provide detailed and helpful answers when the information is available.
        Always cite which document or section your information comes from when possible."""
        
        user_prompt = f"""Based on the following document content, please answer this question: {user_message}

Document Content:
{context}

Please provide a comprehensive answer based on the document content above."""
        
        response = openai_client.chat.completions.create(
            model=config.chat_deployment,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            max_tokens=800,
            temperature=0.3
        )
        
        ai_response = response.choices[0].message.content
        
        logger.info(f"Generated response for query: {user_message}")
        
        return {
            "response": ai_response,
            "sources": sources,
            "status": "success",
            "context_used": len(relevant_chunks)
        }
        
    except Exception as e:
        logger.error(f"Error in chat endpoint: {e}")
        return {
            "response": f"I encountered an error while processing your question: {str(e)}. Please try again or contact support if the issue persists.",
            "sources": [],
            "status": "error",
            "error_details": str(e)
        }

@app.get("/documents")
async def list_documents():
    """List all uploaded documents"""
    try:
        # Try to get from Cosmos DB first, fallback to search index
        try:
            if not cosmos_client:
                raise Exception("Cosmos DB client not available")
                
            database = cosmos_client.get_database_client(config.cosmos_database)
            container = database.get_container_client(config.cosmos_container)
            
            # Query all documents
            query = "SELECT * FROM c"
            documents = list(container.query_items(
                query=query,
                enable_cross_partition_query=True
            ))
            
            # Format response
            document_list = []
            for doc in documents:
                document_list.append({
                    "document_id": doc.get("document_id"),
                    "filename": doc.get("filename"),
                    "upload_date": doc.get("upload_date"),
                    "total_chunks": doc.get("total_chunks"),
                    "total_tokens": doc.get("total_tokens"),
                    "content_preview": doc.get("content_preview", "")[:200] + "..."
                })
            
            return {
                "documents": document_list,
                "count": len(document_list),
                "status": "success",
                "source": "cosmosdb"
            }
            
        except Exception as e:
            logger.warning(f"Failed to query Cosmos DB, using search index: {e}")
            
            # Fallback: Get unique documents from search index
            search_results = search_client.search(
                search_text="*",
                select=["document_id", "document_name", "upload_date"],
                top=1000
            )
            
            # Group by document_id to get unique documents
            unique_docs = {}
            for result in search_results:
                doc_id = result["document_id"]
                if doc_id not in unique_docs:
                    unique_docs[doc_id] = {
                        "document_id": doc_id,
                        "filename": result["document_name"],
                        "upload_date": result.get("upload_date", "Unknown"),
                        "total_chunks": 0,
                        "total_tokens": 0,
                        "content_preview": "Available via search index..."
                    }
                unique_docs[doc_id]["total_chunks"] += 1
            
            document_list = list(unique_docs.values())
            
            return {
                "documents": document_list,
                "count": len(document_list),
                "status": "success",
                "source": "search_index"
            }
        
    except Exception as e:
        logger.error(f"Error listing documents: {e}")
        return {
            "documents": [],
            "count": 0,
            "status": "error",
            "error": str(e)
        }

@app.delete("/documents/{document_id}")
async def delete_document(document_id: str):
    """Delete a document and all its associated data"""
    try:
        # Delete from search index
        search_results = search_client.search(
            search_text="*",
            filter=f"document_id eq '{document_id}'",
            select=["id"]
        )
        
        chunk_ids = [result["id"] for result in search_results]
        if chunk_ids:
            search_client.delete_documents(documents=[{"id": chunk_id} for chunk_id in chunk_ids])
        
        # Delete from Cosmos DB (if available)
        if cosmos_client:
            try:
                database = cosmos_client.get_database_client(config.cosmos_database)
                container = database.get_container_client(config.cosmos_container)
                container.delete_item(item=document_id, partition_key=document_id)
            except Exception as e:
                logger.warning(f"Failed to delete from Cosmos DB: {e}")
        else:
            logger.info("Cosmos DB not available, skipping metadata deletion")
        
        # Delete from blob storage (if available)
        if blob_service_client:
            try:
                # List and delete all blobs with this document_id prefix
                container_client = blob_service_client.get_container_client(config.storage_container)
                blobs = container_client.list_blobs(name_starts_with=f"{document_id}/")
                for blob in blobs:
                    blob_client = blob_service_client.get_blob_client(
                        container=config.storage_container,
                        blob=blob.name
                    )
                    blob_client.delete_blob()
                logger.info(f"Deleted blobs for document {document_id}")
            except Exception as e:
                logger.warning(f"Failed to delete blobs for document {document_id}: {e}")
        else:
            logger.info("Blob storage client not available, skipping blob deletion")
        
        return {
            "message": f"Document {document_id} deleted successfully",
            "document_id": document_id,
            "status": "deleted"
        }
        
    except Exception as e:
        logger.error(f"Error deleting document: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to delete document: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
