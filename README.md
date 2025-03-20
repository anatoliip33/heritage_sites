# HeritageSites API

**This is a simple Elixir-based web API using Plug and Cowboy that reads location data from a CSV file and returns it as JSON.**

## Installation

```bash
git clone https://github.com/anatoliip33/heritage_sites
cd heritage_sites
mix deps.get
mix run --no-halt
```

## API Endpoints  

### GET `api/locations`
**Return all locations from CSV file in JSON.** 

#### Request:  
- **Method:** `GET`  
- **URL:** `http://localhost:4000/api/locations`  
```bash
  curl -X GET "http://localhost:4000/api/locations" -H "Content-Type: application/json"
```

#### Response:  
- **Status code:** `200`
- **Body:**  
  ```json
  {
    [
      {
        "unique_number": "123",
        "id_no": "456",
        "category": "Cultural",
        "date_inscribed": "1992",
        "longitude": "10.12345",
        "latitude": "-45.67890",
        "area_hectares": "100.5",
        "name_en": "Eiffel Tower",
        "short_description_en": "Iconic Paris landmark."
      },
      ...
    ]
  }

### GET `/api/locations?lang={lang}&from={from}&size={size}`
**Filters results based on language, pagination, and required fields.** 

#### Request:  
- **Method:** `GET`  
- **URL:** `http://localhost:4000/api/locations`
- **Query Parameters**
  lang - Language filter (e.g., en, fr, es).
  from - Starting record number.
  size - Number of records to return.  
```bash
  curl -X GET "http://localhost:4000/api/locations?lang=fr&from=10&size=5" -H "Content-Type: application/json"
```

#### Response:  
- **Status code:** `200`
- **Body:**  
  ```json
  {
    [
      {
        "unique_number": "789",
        "id_no": "321",
        "category": "Natural",
        "date_inscribed": "1985",
        "longitude": "-73.935242",
        "latitude": "40.730610",
        "area_hectares": "200.7",
        "name_fr": "Tour Eiffel",
        "short_description_fr": "Un monument célèbre en France."
      },
      ...
    ]
  }

### GET `/api/locations?query_params={query_params}&from={from}&size={size}`
**Filters results based on language, pagination, and required fields.** 

#### Request:  
- **Method:** `GET`  
- **URL:** `http://localhost:4000/api/locations`
- **Query Parameters**
  query_params - Comma-separated string of fields to include.
  from - Starting record number.
  size - Number of records to return.  
```bash
  curl -X GET "http://localhost:4000/api/locations?query_params=name_en,category,date_inscribed&from=5&size=10" -H "Content-Type: application/json"
```

#### Response:  
- **Status code:** `200`
- **Body:**  
  ```json
  {
    [
      {
        "name_en": "Great Wall of China",
        "category": "Cultural",
        "date_inscribed": "1987"
        ...
      },
      ...
    ]
  }    

### GET `/api/locations?lang={lang}&query_params={query_params}&from={from}&size={size}`
**Filters results based on language, pagination, and required fields.** 

#### Request:  
- **Method:** `GET`  
- **URL:** `http://localhost:4000/api/locations`
- **Query Parameters**
  lang - Language filter (e.g., en, fr, es).
  query_params - Comma-separated string of fields to include.
  from - Starting record number.
  size - Number of records to return.  
```bash
  curl -X GET "http://localhost:4000/api/locations?lang=es&query_params=name_es,category,date_inscribed&from=2&size=3" -H "Content-Type: application/json"
```

#### Response:  
- **Status code:** `200`
- **Body:**  
  ```json
  {
    [
      {
        "name_es": "La Alhambra",
        "category": "Cultural",
        "date_inscribed": "1984"
        ...
      },
      ...
    ]
  } 

## Notes
**Ensure the CSV file is correctly formatted and placed in the priv/data/ directory. Modify the parse_line/1 function in the Elixir code if the CSV structure changes.The API supports flexible filtering using query parameters.** 