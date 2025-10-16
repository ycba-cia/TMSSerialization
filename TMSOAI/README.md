# OAI-PMH Rails Application

A Ruby on Rails implementation of the Open Archives Initiative Protocol for Metadata Harvesting (OAI-PMH) version 2.0.

## Overview

This application implements all 6 required OAI-PMH protocol verbs according to the specification at https://www.openarchives.org/OAI/openarchivesprotocol.html

## Requirements

- Ruby 3.x
- Rails 7.1.x
- SQLite3 (or your preferred database)

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd TMSOAI

# Install dependencies
bundle install

# Setup database
rails db:setup

# Start the server
rails server
```

The application will be available at `http://localhost:3000`

## OAI-PMH Endpoints

All OAI-PMH requests are handled through the `/oai` endpoint using GET or POST requests with a `verb` parameter.

### Base URL

```
http://localhost:3000/oai
```

## Implemented Verbs

### 1. Identify

Retrieves information about the repository.

**Required Arguments:** None

**Example Request:**
```bash
curl "http://localhost:3000/oai?verb=Identify"
```

**Response:**
- repositoryName
- baseURL
- protocolVersion (2.0)
- adminEmail
- earliestDatestamp
- deletedRecord
- granularity

**Error Conditions:**
- `badArgument` - Request includes illegal arguments

---

### 2. ListMetadataFormats

Lists available metadata formats that the repository supports.

**Required Arguments:** None

**Optional Arguments:**
- `identifier` - Identifier to check format availability for a specific item

**Example Requests:**
```bash
# List all supported formats
curl "http://localhost:3000/oai?verb=ListMetadataFormats"

# List formats for a specific identifier
curl "http://localhost:3000/oai?verb=ListMetadataFormats&identifier=oai:example.org:item1"
```

**Supported Formats:**
- `oai_dc` - Dublin Core
- `oai_marc` - MARC format

**Error Conditions:**
- `badArgument` - Illegal or missing required arguments
- `idDoesNotExist` - The identifier is unknown or illegal
- `noMetadataFormats` - No metadata formats available

---

### 3. ListSets

Lists the sets available in the repository for selective harvesting.

**Required Arguments:** None

**Optional Arguments:**
- `resumptionToken` - Flow control token (exclusive with other arguments)

**Example Request:**
```bash
curl "http://localhost:3000/oai?verb=ListSets"
```

**Response Structure:**
- setSpec - Set identifier
- setName - Human-readable set name
- setDescription - Optional set description

**Error Conditions:**
- `badArgument` - Illegal arguments or resumptionToken combined with other arguments
- `noSetHierarchy` - Repository does not support sets

---

### 4. ListIdentifiers

Retrieves record headers (abbreviated records) for selective harvesting.

**Required Arguments:**
- `metadataPrefix` - Specifies the metadata format (e.g., `oai_dc`)

**Optional Arguments:**
- `from` - Lower bound for datestamp (YYYY-MM-DD or YYYY-MM-DDThh:mm:ssZ)
- `until` - Upper bound for datestamp
- `set` - Set membership for selective harvesting
- `resumptionToken` - Flow control token (exclusive with other arguments)

**Example Requests:**
```bash
# List all identifiers
curl "http://localhost:3000/oai?verb=ListIdentifiers&metadataPrefix=oai_dc"

# List with date range
curl "http://localhost:3000/oai?verb=ListIdentifiers&metadataPrefix=oai_dc&from=2024-01-01&until=2024-12-31"

# List by set
curl "http://localhost:3000/oai?verb=ListIdentifiers&metadataPrefix=oai_dc&set=set1"
```

**Response:**
Returns headers containing:
- identifier
- datestamp
- setSpec (if applicable)

**Error Conditions:**
- `badArgument` - Illegal or missing required arguments, invalid date format
- `cannotDisseminateFormat` - Unsupported metadata format
- `noRecordsMatch` - No records match the criteria
- `noSetHierarchy` - Repository does not support sets

---

### 5. ListRecords

Retrieves complete records (header + metadata) for harvesting.

**Required Arguments:**
- `metadataPrefix` - Specifies the metadata format (e.g., `oai_dc`)

**Optional Arguments:**
- `from` - Lower bound for datestamp (YYYY-MM-DD or YYYY-MM-DDThh:mm:ssZ)
- `until` - Upper bound for datestamp
- `set` - Set membership for selective harvesting
- `resumptionToken` - Flow control token (exclusive with other arguments)

**Example Requests:**
```bash
# List all records
curl "http://localhost:3000/oai?verb=ListRecords&metadataPrefix=oai_dc"

# List with date range
curl "http://localhost:3000/oai?verb=ListRecords&metadataPrefix=oai_dc&from=2024-01-01&until=2024-12-31"

# List by set
curl "http://localhost:3000/oai?verb=ListRecords&metadataPrefix=oai_dc&set=set1"

# Using MARC format
curl "http://localhost:3000/oai?verb=ListRecords&metadataPrefix=oai_marc"
```

**Response:**
Returns complete records containing:
- header (identifier, datestamp, setSpec)
- metadata (in requested format)
- about (optional)

**Error Conditions:**
- `badArgument` - Illegal or missing required arguments, invalid date format
- `cannotDisseminateFormat` - Unsupported metadata format
- `noRecordsMatch` - No records match the criteria
- `noSetHierarchy` - Repository does not support sets

---

### 6. GetRecord

Retrieves an individual metadata record from the repository.

**Required Arguments:**
- `identifier` - Unique identifier of the item (e.g., `oai:example.org:item1`)
- `metadataPrefix` - Specifies the metadata format (e.g., `oai_dc`)

**Example Requests:**
```bash
# Get a specific record in Dublin Core format
curl "http://localhost:3000/oai?verb=GetRecord&identifier=oai:example.org:item1&metadataPrefix=oai_dc"

# Get a record in MARC format
curl "http://localhost:3000/oai?verb=GetRecord&identifier=oai:example.org:item1&metadataPrefix=oai_marc"
```

**Response:**
Returns a single record containing:
- header (identifier, datestamp, setSpec)
- metadata (in requested format)
- about (optional)

**Error Conditions:**
- `badArgument` - Illegal or missing required arguments
- `cannotDisseminateFormat` - Unsupported metadata format for this item
- `idDoesNotExist` - Identifier is unknown or illegal

---

## Error Handling

The application implements all standard OAI-PMH error codes:

- `badArgument` - Illegal or missing required arguments
- `badResumptionToken` - Invalid or expired resumption token
- `badVerb` - Illegal or missing verb argument
- `cannotDisseminateFormat` - Unsupported metadata format
- `idDoesNotExist` - Unknown or illegal identifier
- `noRecordsMatch` - No records match the query criteria
- `noMetadataFormats` - No metadata formats available
- `noSetHierarchy` - Repository does not support sets

## Sample Data

The application includes sample records for testing:

- **oai:example.org:item1** - Sample Record 1 (in set1)
- **oai:example.org:item2** - Sample Record 2 (in set2)

## Configuration

You can configure repository settings in `app/controllers/oai_controller.rb`:

```ruby
REPOSITORY_NAME = "Sample OAI-PMH Repository"
BASE_URL = "http://localhost:3000/oai"
ADMIN_EMAIL = "admin@example.com"
EARLIEST_DATESTAMP = "2020-01-01T00:00:00Z"
```

## Metadata Formats

### Dublin Core (oai_dc)

Standard Dublin Core elements:
- dc:title
- dc:creator
- dc:subject
- dc:description
- dc:publisher
- dc:date
- dc:type
- dc:identifier

### MARC (oai_marc)

Simplified MARC format with basic fields.

## Testing with cURL

```bash
# Test Identify
curl "http://localhost:3000/oai?verb=Identify"

# Test ListMetadataFormats
curl "http://localhost:3000/oai?verb=ListMetadataFormats"

# Test ListSets
curl "http://localhost:3000/oai?verb=ListSets"

# Test ListIdentifiers
curl "http://localhost:3000/oai?verb=ListIdentifiers&metadataPrefix=oai_dc"

# Test ListRecords
curl "http://localhost:3000/oai?verb=ListRecords&metadataPrefix=oai_dc"

# Test GetRecord
curl "http://localhost:3000/oai?verb=GetRecord&identifier=oai:example.org:item1&metadataPrefix=oai_dc"

# Test error handling
curl "http://localhost:3000/oai?verb=GetRecord&identifier=invalid&metadataPrefix=oai_dc"
```

## Extending the Application

### Adding Real Data

Currently, the application uses sample data defined in the `sample_records` method. To connect to a real database:

1. Create a Record model with the required fields
2. Replace `sample_records` with database queries
3. Update `identifier_exists?` and `find_record` methods
4. Implement pagination with resumption tokens for large datasets

### Adding Metadata Formats

To add new metadata formats:

1. Add format definition to `SUPPORTED_FORMATS` constant
2. Update `build_metadata` method with new format handler
3. Ensure proper XML namespaces and schema locations

## API Compliance

This implementation follows the OAI-PMH 2.0 specification including:

- Proper XML response structure
- Standard error codes
- Date/time granularity support
- Set hierarchy support
- Multiple metadata format support
- Resumption token framework (ready for implementation)

## License

MIT License

## References

- [OAI-PMH Specification](https://www.openarchives.org/OAI/openarchivesprotocol.html)
- [Dublin Core Metadata Initiative](https://dublincore.org/)
