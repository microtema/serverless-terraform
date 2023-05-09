const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();
const TableName = process.env.TABLE_NAME;

module.exports.handler = async (event) => {

    const {product_id} = event.queryStringParameters

    const params = {
        TableName,
        KeyConditionExpression: '#name = :value',
        ExpressionAttributeValues: {':value': product_id},
        ExpressionAttributeNames: {'#name': 'product_id'}
    }

    try {
        const data = await docClient.query(params).promise()
        return {
            statusCode: 200,
            body: JSON.stringify(data.Items)
        }
    } catch (e) {
        return {error: "Unable to query document!", message: e.message}
    }
}