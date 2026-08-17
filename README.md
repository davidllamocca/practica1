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


    A1["n8n<br/>Cron 06:00 a.m."]
    A2["APIs externas<br/>OpenAQ, SENAMHI"]
    A3[("PostgreSQL<br/>Guarda datos limpios")]
    A4["LLM multi-modelo<br/>Detecta anomalías"]
    A5["Telegram<br/>Alerta si hay anomalía"]

    A1 -->|1| A2
    A2 -->|2| A3
    A3 -->|3| A4
    A4 -->|4| A5 


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

Descripción de Componentes de la Arquitectura
Usuario [Persona]: Usuario final que interactúa con la interfaz web realizando consultas en lenguaje natural o visualizando métricas ambientales.

Frontend [Container: React/Vue]: Capa de presentación que captura las peticiones del usuario, gestiona el estado de la interfaz y renderiza las respuestas mediante componentes visuales.

n8n — Orquestador [Container: Self-hosted]: Núcleo de automatización que gestiona los flujos de datos, los desencadenadores (triggers HTTP y temporizadores) y la integración entre los distintos servicios.

PostgreSQL (BD vectorial / RAG): Sistema de almacenamiento unificado que guarda registros históricos estructurados y vectores numéricos (embeddings) para búsquedas por similitud semántica.

LLM multi-modelo (failover): Motor de inteligencia artificial que procesa contextos para responder preguntas y detectar anomalías, con capacidad de conmutación automática entre proveedores ante eventuales caídas del servicio principal.

IA Ops / MLOps [Container: LangSmith/Langfuse]: Módulo transversal de observabilidad encargado del monitoreo de latencia, consumo de tokens, costos, auditoría de ejecuciones y trazabilidad global del modelo.

APIs externas (OpenAQ, SENAMHI): Fuentes de información meteorológica y de calidad del aire que alimentan el proceso de ingesta programada.

Telegram: Canal externo de mensajería configurado para la recepción automática de alertas de emergencia ante mediciones fuera de norma.

Secuencia del Flujo A: Ingesta Diaria + Detección de Anomalías
Este flujo se ejecuta en segundo plano como un proceso batch programado para mantener actualizada la base de datos y emitir alertas tempranas:

Ejecución Programada: Un temporizador interno en n8n activa el flujo de manera automática todos los días a las 06:00 a.m.

Consulta a Fuentes Externas: n8n realiza peticiones HTTP a las APIs externas de OpenAQ y SENAMHI para extraer las lecturas más recientes.

Procesamiento y Persistencia: El orquestador estandariza las mediciones y las guarda estructuradamente dentro de PostgreSQL.

Análisis de Anomalías: La información registrada se evalúa mediante el LLM multi-modelo para determinar picos inusuales de contaminación o comportamientos atípicos.

Emisión de Alertas: En caso de confirmarse un patrón anómalo, n8n despacha una notificación de alerta hacia el canal de Telegram.

Secuencia del Flujo B: Natural Language Query (NLQ) + RAG
Este flujo atiende en tiempo real las solicitudes conversacionales formuladas por el usuario desde la plataforma web:

Entrada de Consulta: El usuario escribe una pregunta en lenguaje natural a través de la interfaz del Frontend.

Recepción Webhook: El Frontend envía una petición HTTP POST /nlq hacia el punto de entrada de n8n.

Búsqueda Semántica (RAG): n8n ejecuta una consulta vectorial en PostgreSQL (pgvector) para extraer el contexto histórico más relevante en función de la pregunta.

Generación de Respuesta: La consulta original enriquecida con el contexto recuperado se transfiere al LLM multi-modelo, el cual construye una respuesta precisa y fundamentada.

Formateo de Salida: n8n convierte la respuesta recibida en una estructura de datos JSON estandarizada.

Renderizado Visual: El Frontend procesa el archivo JSON y genera gráficos dinámicos interactivos mediante Chart.js.