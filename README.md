# Arquitectura del Sistema - EcoPredict & NLQ

Este documento describe la arquitectura general en 5 capas y la secuencia detallada de los dos flujos principales del proyecto EcoPredict & NLQ.

---

## 1. Arquitectura General del Sistema

```mermaid
flowchart TD
    U["Usuario<br/>[Persona]"]

    subgraph EcoPredict ["EcoPredict & NLQ"]
        FE["Frontend<br/>[Container: React/Vue]"]
        N8N["n8n — Orquestador<br/>[Container: Self-hosted]"]
        DB[("PostgreSQL<br/>BD vectorial (RAG)")]
        LLM["LLM multi-modelo<br/>Multimodelo (failover)"]
        IAOPS["IA Ops / MLOps<br/>[Container: LangSmith/Langfuse]"]
    end

    EXT_API["APIs externas<br/>OpenAQ, SENAMHI"]
    TG["Telegram<br/>Canal externo"]

    U --> FE
    FE --> N8N
    EXT_API --> N8N
    N8N --> DB
    N8N --> LLM
    DB <--->|RAG| LLM
    LLM --> TG
    DB --> IAOPS
    LLM --> IAOPS

    flowchart TD
    A1["n8n<br/>Cron 06:00 a.m."]
    A2["APIs externas<br/>OpenAQ, SENAMHI"]
    A3[("PostgreSQL<br/>Guarda datos limpios")]
    A4["LLM multi-modelo<br/>Detecta anomalías"]
    A5["Telegram<br/>Alerta si hay anomalía"]

    A1 -->|1| A2
    A2 -->|2| A3
    A3 -->|3| A4
    A4 -->|4| A5

    flowchart TD
    B1["Frontend<br/>Usuario escribe pregunta"]
    B2["n8n<br/>Webhook POST /nlq"]
    B3[("PostgreSQL<br/>RAG: recupera contexto")]
    B4["LLM multi-modelo<br/>Responde con contexto"]
    B5["n8n<br/>Formatea respuesta JSON"]
    B6["Frontend<br/>Chart.js renderiza gráfico"]

    B1 -->|1| B2
    B2 -->|2| B3
    B3 -->|3| B4
    B4 -->|4| B5
    B5 -->|5| B6