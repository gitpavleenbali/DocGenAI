import React, { useState, useEffect } from 'react';
import './App.css';
import { 
  FluentProvider, 
  webLightTheme, 
  Button, 
  Card, 
  CardHeader, 
  Text,
  Input,
  Textarea,
  MessageBar,
  Spinner
} from '@fluentui/react-components';
import { CloudArrowUp24Regular, Chat24Regular } from '@fluentui/react-icons';

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'https://ca-api-dev-varcvenlme53e.agreeabledesert-fe9fb50b.eastus2.azurecontainerapps.io';

function App() {
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [uploadMessage, setUploadMessage] = useState<{ text: string; intent: 'error' | 'success' | 'warning' | 'info' } | null>(null);
  const [documents, setDocuments] = useState<any[]>([]);
  const [chatMessage, setChatMessage] = useState('');
  const [chatResponse, setChatResponse] = useState('');
  const [isChatting, setIsChatting] = useState(false);

  const loadDocuments = async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/documents`);
      if (response.ok) {
        const result = await response.json();
        setDocuments(result.documents || []);
      }
    } catch (error) {
      console.error('Failed to load documents:', error);
    }
  };

  // Load documents on component mount
  useEffect(() => {
    loadDocuments();
  }, []);

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      if (file.type === 'application/pdf') {
        setSelectedFile(file);
        setUploadMessage(null);
      } else {
        setUploadMessage({ text: 'Please select a PDF file only', intent: 'error' });
        setSelectedFile(null);
      }
    }
  };

  const handleUpload = async () => {
    if (!selectedFile) return;

    setIsUploading(true);
    const formData = new FormData();
    formData.append('file', selectedFile);

    try {
      const response = await fetch(`${API_BASE_URL}/documents/upload`, {
        method: 'POST',
        body: formData,
      });

      if (response.ok) {
        const result = await response.json();
        setUploadMessage({ text: `Document uploaded successfully!`, intent: 'success' });
        setSelectedFile(null);
        loadDocuments();
      } else {
        const error = await response.json();
        setUploadMessage({ text: `Upload failed: ${error.detail || 'Unknown error'}`, intent: 'error' });
      }
    } catch (error) {
      setUploadMessage({ text: `Upload failed: ${error}`, intent: 'error' });
    } finally {
      setIsUploading(false);
    }
  };

  const handleChat = async () => {
    if (!chatMessage.trim()) return;

    setIsChatting(true);
    try {
      const response = await fetch(`${API_BASE_URL}/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ message: chatMessage }),
      });

      if (response.ok) {
        const result = await response.json();
        setChatResponse(result.response || 'No response received');
      } else {
        setChatResponse('Chat failed. Please try again.');
      }
    } catch (error) {
      setChatResponse(`Chat error: ${error}`);
    } finally {
      setIsChatting(false);
    }
  };

  React.useEffect(() => {
    loadDocuments();
  }, []);

  return (
    <FluentProvider theme={webLightTheme}>
      <div className="App" style={{ padding: '20px', maxWidth: '1200px', margin: '0 auto' }}>
        <header style={{ textAlign: 'center', marginBottom: '40px' }}>
          <h1>🤖 DocGenAI - Document Analysis</h1>
          <p>Upload PDF documents and chat with them using Azure AI</p>
        </header>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px', marginBottom: '20px' }}>
          {/* Upload Section */}
          <Card>
            <CardHeader
              header={
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <CloudArrowUp24Regular />
                  <Text weight="semibold">Upload Document</Text>
                </div>
              }
            />
            <div style={{ padding: '16px' }}>
              <input
                type="file"
                accept=".pdf"
                onChange={handleFileSelect}
                style={{ marginBottom: '16px', width: '100%' }}
              />
              {selectedFile && (
                <Text>Selected: {selectedFile.name}</Text>
              )}
              <Button 
                appearance="primary" 
                onClick={handleUpload}
                disabled={!selectedFile || isUploading}
                style={{ width: '100%', marginTop: '16px' }}
              >
                {isUploading ? <Spinner size="tiny" /> : 'Upload PDF'}
              </Button>
              {uploadMessage && (
                <MessageBar intent={uploadMessage.intent} style={{ marginTop: '16px' }}>
                  {uploadMessage.text}
                </MessageBar>
              )}
            </div>
          </Card>

          {/* Chat Section */}
          <Card>
            <CardHeader
              header={
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <Chat24Regular />
                  <Text weight="semibold">Chat with Documents</Text>
                </div>
              }
            />
            <div style={{ padding: '16px' }}>
              <Textarea
                placeholder="Ask a question about your documents..."
                value={chatMessage}
                onChange={(e) => setChatMessage(e.target.value)}
                style={{ width: '100%', marginBottom: '16px' }}
              />
              <Button 
                appearance="primary" 
                onClick={handleChat}
                disabled={!chatMessage.trim() || isChatting}
                style={{ width: '100%' }}
              >
                {isChatting ? <Spinner size="tiny" /> : 'Ask Question'}
              </Button>
              {chatResponse && (
                <div style={{ marginTop: '16px', padding: '12px', backgroundColor: '#f5f5f5', borderRadius: '4px' }}>
                  <Text>{chatResponse}</Text>
                </div>
              )}
            </div>
          </Card>
        </div>

        {/* Documents List */}
        <Card>
          <CardHeader
            header={<Text weight="semibold">Uploaded Documents ({documents.length})</Text>}
          />
          <div style={{ padding: '16px' }}>
            {documents.length === 0 ? (
              <Text>No documents uploaded yet. Upload a PDF to get started!</Text>
            ) : (
              <ul>
                {documents.map((doc, index) => (
                  <li key={index} style={{ marginBottom: '8px' }}>
                    <Text>{doc.name || `Document ${index + 1}`}</Text>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </Card>

        <footer style={{ textAlign: 'center', marginTop: '40px', padding: '20px' }}>
          <Text size={200}>
            Powered by Azure AI Foundry, Azure OpenAI, and Microsoft Copilot Studio
          </Text>
        </footer>
      </div>
    </FluentProvider>
  );
}

export default App;
