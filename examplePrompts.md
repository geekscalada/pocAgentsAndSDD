
# Orquestación
"Analiza este texto e identifica el tema central, luego escribe un párrafo de introducción basado en ese análisis: "El cambio climático afecta a todos los ecosistemas del planeta. Los científicos alertan de consecuencias irreversibles si no actuamos."

# Skills

Tengo el siguiente fragmento de documentación técnica de un sistema:

"Give your agents persistent storage for sessions, context, memory and knowledge.

Databases are a foundational part of agent engineering. Add a database to your agent and you get persistent storage for sessions, context, memory, learnings, and evaluation datasets.
Chat history. Include previous messages in context for multi-turn conversations.
Session persistence. Store session information and conversation history across requests.
State management. Store internal agent state across runs. Critical for planning agents.
Context control. Summarize, compress, enrich, and prune context for better responses.
Memory and knowledge. Store user-level facts, searchable knowledge, decision traces, and learned insights.
Tracing and evaluation. Store detailed traces for debugging, monitoring, and building evaluation datasets.
Data ownership. No third-party dependencies. Query your own database. Build evaluation datasets, extract few-shot examples, flag low-quality responses for review.
This is how good software is built. Agents are no different.
​
Quick Start
from agno.agent import Agent
from agno.db.sqlite import SqliteDb

agent = Agent(
db=SqliteDb(db_file="agent.db"),
add_history_to_context=True,
num_history_runs=3,
)

First message
agent.print_response("I'm working on a Python API project", session_id="dev_session")

Later — agent remembers the context
agent.print_response("What testing framework should I use?", session_id="dev_session")
The agent now persists sessions and includes the last 3 runs in every request."

Necesito dos cosas: primero, que lo analices en detalle identificando sus componentes, relaciones y puntos críticos; y segundo, que con ese análisis generes una ficha ejecutiva clara y estructurada lista para compartir con el equipo.

# Ejecutar skills
/dummy-skill Dime qué agente eres y qué skill tienes cargada


