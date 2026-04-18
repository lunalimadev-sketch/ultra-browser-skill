const { Client } = require('pg');

async function main() {
  const client = new Client({
    host: '127.0.0.1',
    port: 54329,
    database: 'paperclip',
    user: 'paperclip',
    password: 'paperclip'
  });

  await client.connect();
  
  const sql = `
    UPDATE agents 
    SET adapter_config = adapter_config || '{"headers": {"x-openclaw-token": "a8df8a4b175b67679f67c4796223c09d6cd6b2c93f5b0bbf"}}'::jsonb 
    WHERE adapter_type = 'openclaw_gateway'
  `;
  
  const result = await client.query(sql);
  console.log('Rows updated:', result.rowCount);
  
  await client.end();
}

main().catch(console.error);