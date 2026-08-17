## Arquitectura del Sistema (EcoPredict & NLQ)

```mermaid
flowchart TD
    U["👤 Usuario<br/>[Persona]"]

    subgraph EcoPredict ["🏛️ EcoPredict & NLQ"]
        FE["🖥️ Frontend<br/>[Container: React/Vue]"]
        N8N["⚙️ n8n — Orquestador<br/>[Container: Self-hosted]"]
        
        DB[("🛢️ PostgreSQL<br/>BD vectorial (RAG)")]
        LLM["🤖 LLM multi-modelo<br/>Multimodelo (failover)"]
        
        IAOPS["📊 IA Ops / MLOps<br/>[Container: LangSmith/Langfuse]"]
    end

    EXT_API["🌐 APIs externas<br/>OpenAQ, SENAMHI"]
    TG["📲 Telegram<br/>Canal externo"]

    %% Conexiones
    U --> FE
    FE --> N8N
    EXT_API --> N8N
    N8N --> DB
    N8N --> LLM
    DB <--->|RAG| LLM
    LLM --> TG
    DB --> IAOPS
    LLM --> IAOPS