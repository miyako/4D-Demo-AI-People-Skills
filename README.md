# 4D Demo AI People & Skills

A demonstration project showcasing AI-powered employee data generation, vector embeddings, and semantic search capabilities using 4D and OpenAI-compatible APIs.

## 🎯 Purpose

This project demonstrates how to leverage Large Language Models (LLMs) and vector embeddings in a 4D application for:

1. **AI-Driven Data Generation**: Automatically generate realistic employee profiles including personal information, skills, addresses, and job details using structured LLM outputs
2. **Vector Embeddings**: Convert employee data into vector representations for semantic similarity searches
3. **Semantic Search**: Query employees using natural language descriptions rather than exact field matches
4. **AI Agent with Tools**: Implement an AI assistant that can search your database using custom function calling tools

### Key Features

- **Synthetic Data Generation**: Generate hundreds of realistic employee profiles with validated schemas
- **Vector Database**: Store and query employee embeddings for similarity-based searches
- **Multiple AI Providers**: Support for OpenAI, Ollama, and other OpenAI-compatible APIs
- **Function Calling**: AI agent with custom tools for semantic employee search
- **Real-time Progress**: Stream responses and track generation/vectorization progress
- **Data Validation**: JSON schema validation for generated data integrity

## 🏗️ Architecture

The project consists of several key components:

### Classes

- **AI_Agent**: Base class for AI operations, handles provider and model configuration
- **AI_PeopleGenerator**: Generates synthetic employee data using LLMs with structured output
- **AI_PersonVectorizer**: Creates vector embeddings from employee descriptive phrases
- **AI_QuestionningTools**: Implements custom tools for AI function calling (search by vector, list skills, etc.)
- **personEntity**: Employee entity with computed attributes and descriptive phrase generation
- **addressEntity**: Address validation and formatting

### Database Schema

The project uses these main tables:
- **person**: Employee personal information (name, email, phone, birth date, gender)
- **address**: Complete address details with validation
- **personSkills**: Junction table linking persons to skills with experience and level
- **skill**: Skills catalog with categories
- **jobDetail**: Employment information (hire date, job title, billing rate, notes)
- **embeddingInfo**: Tracks embedding generation metadata

### AI Components

The project uses the **4D-AIKit** component which provides:
- OpenAI API client
- Chat completion helpers
- Streaming support
- Asynchronous operations

## 📋 Prerequisites

- **4D 21** or later
- An **OpenAI API key** or access to an **OpenAI-compatible API** (like Ollama)
- Internet connection (for cloud AI providers)
- Sufficient API credits or **local LLM setup**

## 🚀 Setup Instructions

### 1. Clone the Repository


### 2. Configure AI Providers

Edit the `Resources/AIProviders.json` file to add your API credentials:

```json
[
  {
    "name": "OpenAI",
    "url": "",
    "key": "YOUR_OPENAI_API_KEY_HERE",
    "defaults": {
      "embedding": "text-embedding-ada-002",
      "reasoning": "gpt-4.1-2025-04-14"
    }
  },
  {
    "name": "Ollama",
    "url": "http://localhost:11434/v1",
    "key": "",
    "defaults": {
      "embedding": "",
      "reasoning": ""
    }
  },
  {
    "name": "LM Studio",
    "url": "http://localhost:1234/v1",
    "key": "",
    "defaults": {
      "embedding": "",
      "reasoning": ""
    }
  }
]
```

Note that this file is only used at first launch. Once providers are loaded in database, it is ignored. Use the Demo app forms to update providers details.

**Options:**
- **OpenAI**: Add your API key in the `key` field
- **Ollama**: Install [Ollama](https://ollama.ai/) locally and ensure it's running on port 11434
- **LM Studio**: Install [LM Studio](https://lmstudio.ai/) locally and ensure it's running on port 1234
- **Other providers**: Add custom OpenAI-compatible endpoints

### 3. Open the Project in 4D

1. Launch **4D** application
2. Open the project file: `Project/4D_Demo_AI_People_Skills.4DProject`
3. The project will automatically:
   - Load the 4D-AIKit component
   - Initialize provider settings from `AIProviders.json`

### 4. Initial Database Setup

The first time you run the project:

1. The database will be already filled with sample data, already with embeddings
2. Navigate to **"Data Gen & Embeddings 🪄"** section
3. Generate more employee data if you want (see Usage section below)
4. Ensure you have the embedding model used for this database available, or generate new embeddings

### 5. Verify Installation

Check that:
- ✅ The project opens without errors
- ✅ The menu appears with options: "Intro", "Data Gen & Embeddings", "Semantic search", "Question me with tools"
- ✅ Your AI provider is accessible (test with a small data generation)
- ✅ You have an available embedding model and embeddings generated accordingly (test with a semantic search)

## 📖 Usage

### Generating Employee Data

1. Go to **"Data Gen & Embeddings 🪄"** in the main menu
2. Select your AI provider and model for data generation
3. Enter the number of employees to generate
4. Add optional specific requests (e.g., "include developers from Europe")
5. Click **"Generate People"**
6. Watch the real-time progress as the AI generates realistic profiles

The system will:
- Generate employees in batches
- Validate data against JSON schemas
- Store valid records in the database
- Skip invalid entries and retry

### Creating Vector Embeddings

After generating employee data:

1. In the **"Data Gen & Embeddings 🪄"** section
2. Select your embedding provider and model
3. Choose whether to recompute all embeddings or only new ones
4. Click **"Vectorize"**
5. Wait for the vectorization process to complete

This creates vector representations of each employee's full profile (identity, skills, job details, address).

### Semantic Search

1. Navigate to **"Semantic search"**
2. Enter a natural language query like:
   - "senior frontend developers expert in React living in Europe"
   - "project managers hired around 2020 with Agile experience"
   - "Python developers in New York"
3. View matching employees ranked by semantic similarity

### AI Assistant with Tools

1. Go to **"Question me with tools 🪄"**
2. Select your AI provider and reasoning model
3. Ask questions in natural language:
   - "Find me 3 developers who know JavaScript and live in California"
   - "Who are the most experienced project managers?"
   - "List all available skills in the database"
4. The AI will use custom tools to search and answer

The AI agent has access to:
- `tool_PersonSearchByVector`: Semantic employee search
- `tool_listSkillsAndCategories`: Get all skills and their categories
- `tool_listCitiesAndCountries`: Get all locations in the database
- `tool_listJobTitles`: Get all job titles

## 🔧 Configuration Files

### AIProviders.json
Defines available AI providers, URLs, API keys, and default models.

### AITools.json
Defines custom function calling tools available to the AI agent with detailed schemas and examples.

### personArraySchema.json
JSON schema for validating generated employee data structure.

## 🧪 Example Queries

### Data Generation
- "Generate 50 employees with diverse skills"
- "Create developers specializing in web technologies from North America"
- "Generate project managers with Agile certifications"

### Semantic Search
- "Expert Python developers with machine learning experience"
- "Frontend developers in major European cities"
- "Recently hired senior engineers with over 10 years experience"

### AI Assistant
- "Find me the top 5 most experienced React developers"
- "Who are the project managers living in the United States?"
- "What skills are available in the database?"

## 🤝 Contributing

This is a demonstration project. Feel free to:
- Fork and experiment
- Suggest improvements
- Report issues
- Share your use cases

## 📄 License

See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **4D-AIKit Component**: Provides the OpenAI API integration layer

## 📞 Support

For questions about:
- **4D specific issues**: Check [4D documentation](https://developer.4d.com/)
- **AI integration**: Review the 4D AIKit documentation in [4D AI Kit documentation](https://developer.4d.com/docs/aikit/overview)
- **Project specific**: Bring your questions on [4D Forum](https://discuss.4d.com)

---

**Note**: This project is for demonstration purposes. Generated employee data is synthetic and not based on real individuals.