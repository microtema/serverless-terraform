const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();
const TableName = process.env.TABLE_NAME;

module.exports.handler = async (event) => {

    const params = {
        TableName,
        Key: {...event.queryStringParameters}
    }

    try {
        const data = await docClient.get(params).promise()
        return {body: JSON.stringify(data.Item)}
    } catch (e) {
        return {error: "Unable to get document!", message: e.message}
    }
}