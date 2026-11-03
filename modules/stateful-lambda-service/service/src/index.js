const { DynamoDBClient, GetItemCommand, UpdateItemCommand } = require("@aws-sdk/client-dynamodb");

const tableName = process.env.DYNAMODB_TABLE;
const client = new DynamoDBClient();

async function getCount() {
  const result = await client.send(new GetItemCommand({
    TableName: tableName,
    Key: { Id: { S: "postCounter" } },
  }));

  if (!result.Item) {
    return 0;
  }

  return parseInt(result.Item.count.N, 10);
}

exports.handler = async (event) => {
  const method = event.requestContext.http.method;

  if (method === "GET") {
    const count = await getCount();
    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ count }),
    };
  }

  if (method === "POST") {
    await client.send(new UpdateItemCommand({
      TableName: tableName,
      Key: { Id: { S: "postCounter" } },
      UpdateExpression: "ADD #count :incr",
      ExpressionAttributeNames: { "#count": "count" },
      ExpressionAttributeValues: { ":incr": { N: "1" } },
      ReturnValues: "UPDATED_NEW",
    }));

    const count = await getCount();
    console.log(`Updated counter to ${count}`);

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ count }),
    };
  }

  return {
    statusCode: 405,
    body: "Method Not Allowed",
  };
};
