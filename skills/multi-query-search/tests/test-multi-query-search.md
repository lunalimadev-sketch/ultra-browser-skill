# Multi-Query Search — Test Suite

Validates the query decomposition strategy against the SKILL.md specification.

## Test Structure

Each test case includes:
- **Input:** The user's original query
- **Expected decomposition:** What the 5 queries should look like
- **Validation criteria:** What makes the decomposition correct

---

## Test 1: Simple English Query

**Input:** "What is the impact of transformer architecture on modern NLP?"

**Expected:**
1. **Precision:** `"impact transformer architecture modern NLP"`
2. **Recall:** `"transformer NLP"`
3. **Temporal (QDF=1):** `"transformer architecture NLP impact"` → `freshness: "year"`
4. **Semantic:** `"self-attention mechanism language model pre-training BERT GPT"`
5. **Multilingual:** *(skip — query is in English)*

**Validates:**
- [ ] Precision query uses exact terms from user
- [ ] Recall query is ≤3 keywords
- [ ] Temporal defaults to QDF=1 (general info, not time-critical)
- [ ] Semantic includes related concepts (attention, pre-training, models)
- [ ] No multilingual query generated for English input

---

## Test 2: Recent News Query (Portuguese)

**Input:** "Quais são as últimas notícias sobre regulação de IA na Europa?"

**Expected:**
1. **Precision:** `"regulação IA Europa últimas notícias"`
2. **Recall:** `"AI regulation Europe"`
3. **Temporal (QDF=5):** `"AI regulation Europe news 2026"` → `freshness: "day"`
4. **Semantic:** `"EU AI Act legislation policy governance compliance"`
5. **Multilingual (5a):** `"AI regulation Europe latest news"`
6. **Multilingual (5b):** `"regulamentação inteligência artificial Europa notícias"`

**Validates:**
- [ ] Portuguese query generates multilingual queries (5a + 5b)
- [ ] "últimas" triggers QDF=5 (most recent)
- [ ] Temporal uses `freshness: "day"`
- [ ] Semantic includes EU-specific terms (AI Act, governance)

---

## Test 3: Historical Research Query

**Input:** "Tell me about the history of neural networks from the 1950s to today"

**Expected:**
1. **Precision:** `"history neural networks 1950s present evolution"`
2. **Recall:** `"neural network history"`
3. **Temporal (QDF=0):** `"neural networks history origins perceptron"` → *(no freshness)*
4. **Semantic:** `"perceptron backpropagation deep learning perceptron Markov Boltzmann machine"`
5. **Multilingual:** *(skip — English input)*

**Validates:**
- [ ] "history" and date range (1950s) triggers QDF=0 (historical)
- [ ] No freshness filter applied for QDF=0
- [ ] Semantic spans the full timeline (perceptron → deep learning)

---

## Test 4: Technical Implementation Query

**Input:** "Como implementar RAG com vector database usando LangChain?"

**Expected:**
1. **Precision:** `"implementar RAG vector database LangChain"`
2. **Recall:** `"RAG LangChain vector"`
3. **Temporal (QDF=2):** `"RAG LangChain vector database implementation"` → `freshness: "month"`
4. **Semantic:** `"retrieval augmented generation embeddings FAISS ChromaDB Pinecone chunking"`
5. **Multilingual (5a):** `"implement RAG vector database LangChain"`
6. **Multilingual (5b):** `"implementação RAG banco vetorial LangChain"`

**Validates:**
- [ ] Technical terms preserved exactly (RAG, LangChain)
- [ ] QDF=2 for technical implementation (moderately recent)
- [ ] Semantic includes specific vector DB options
- [ ] Bilingual queries generated

---

## Test 5: Multi-Entity Complex Query

**Input:** "Compare OpenAI, Anthropic, and Google's approaches to AI safety in 2025-2026"

**Expected:**
1. **Precision:** `"OpenAI Anthropic Google AI safety comparison 2025 2026"`
2. **Recall:** `"AI safety companies"`
3. **Temporal (QDF=4):** `"OpenAI Anthropic Google AI safety 2026"` → `freshness: "week"`
4. **Semantic:** `"alignment RLHF constitutional AI red teaming safety benchmark evaluation"`
5. **Multilingual:** *(skip — English input)*

**Validates:**
- [ ] All 3 entities included in precision query
- [ ] Date range (2025-2026) triggers QDF=4 (recent)
- [ ] Semantic captures safety-specific terminology (alignment, RLHF, constitutional)
- [ ] Entities boosted or prioritized

---

## Test 6: Navigational Intent

**Input:** "Find the deployment guide for our Paperclip server"

**Expected:**
1. **Precision:** `"deployment guide Paperclip server"`
2. **Recall:** `"Paperclip deploy"`
3. **Temporal (QDF=2):** `"Paperclip server deployment guide"` → `freshness: "month"`
4. **Semantic:** `"installation configuration WSL portproxy setup"`
5. **Intent tag:** `nav` (navigational)

**Validates:**
- [ ] Intent `nav` is tagged (user is looking for a specific document)
- [ ] Semantic includes deployment-related concepts
- [ ] memory_search should be included for workspace context

---

## Test 7: No Temporal Intent (Stable Knowledge)

**Input:** "Explain the CAP theorem in distributed systems"

**Expected:**
1. **Precision:** `"CAP theorem distributed systems explanation"`
2. **Recall:** `"CAP theorem"`
3. **Temporal (QDF=0):** `"CAP theorem distributed consistency availability partition"` → *(no freshness)*
4. **Semantic:** `"Brewer conjecture ACID BASE eventual consistency Raft Paxos"`
5. **Multilingual:** *(skip — English input)*

**Validates:**
- [ ] QDF=0 for foundational CS concept (stable knowledge)
- [ ] No freshness filter
- [ ] Semantic includes related distributed systems concepts

---

## Test 8: Urgent/Breaking Query

**Input:** "Breaking: any security vulnerability in npm packages today?"

**Expected:**
1. **Precision:** `"npm security vulnerability today"`
2. **Recall:** `"npm vulnerability"`
3. **Temporal (QDF=5):** `"npm security vulnerability 2026"` → `freshness: "day"`
4. **Semantic:** `"CVE supply chain attack dependency audit"`
5. **Multilingual:** *(skip — English input)*

**Validates:**
- [ ] "today" and "breaking" trigger QDF=5 (most recent)
- [ ] `freshness: "day"` applied
- [ ] Semantic includes security-specific terms (CVE, supply chain)

---

## Test 9: Cross-Domain Query

**Input:** "How does quantum computing affect cryptography and blockchain?"

**Expected:**
1. **Precision:** `"quantum computing impact cryptography blockchain"`
2. **Recall:** `"quantum cryptography"`
3. **Temporal (QDF=2):** `"quantum computing cryptography blockchain"` → `freshness: "month"`
4. **Semantic:** `"Shor algorithm post-quantum lattice-based NIST standardization"`
5. **Multilingual:** *(skip — English input)*

**Validates:**
- [ ] Cross-domain terms (quantum + crypto + blockchain) all included
- [ ] Semantic captures specific algorithms (Shor) and standards (NIST)
- [ ] QDF=2 for evolving field

---

## Test 10: Fallback to Memory Search

**Input:** "What decisions did we make about the Paperclip API configuration last week?"

**Expected:**
1. **Precision:** `"Paperclip API configuration decisions last week"`
2. **Recall:** `"Paperclip config"`
3. **Temporal (QDF=4):** *(apply to web_search)* `freshness: "week"`
4. **Semantic:** *(apply to web_search)* `"API key portproxy WSL setup"`
5. **Memory search:** `memory_search("Paperclip API configuration")`

**Validates:**
- [ ] memory_search is invoked for workspace-specific context
- [ ] Web search and memory search run in parallel
- [ ] Results from both sources are merged

---

## Validation Checklist

For each test, verify:

| Check | Description |
|-------|-------------|
| Query count | ≤5 web searches + memory search if applicable |
| Self-contained | Each query is understandable standalone |
| QDF mapping | Temporal intent correctly maps to freshness parameter |
| Boost operators | Entity emphasis used where provider supports it |
| Bilingual | Multilingual queries only for non-English input |
| Intent tag | `nav` only when user searches for specific document |
| No duplicates | Queries use distinct terms, not repetitive phrasing |
| Provider compat | Queries work with Brave, Perplexity, Exa, and Gemini |

---

## Running Tests

To validate a decomposition against these test cases:

1. Feed the input query to the agent with the skill loaded
2. Capture the generated queries
3. Compare against expected decomposition
4. Check all validation criteria
5. Score: pass/fail per criterion

```bash
# Example manual test
openclaw agent --message "Using multi-query-search skill, decompose: 'What is the impact of transformer architecture on modern NLP?'"
```

Expected output should contain 3-4 queries (no multilingual for English input).
