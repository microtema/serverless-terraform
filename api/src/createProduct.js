const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();
const TableName = process.env.TABLE_NAME;

module.exports.handler = async (event) => {

    const Item = JSON.parse(event.body);

    const params = {TableName, Item}

    try {
        await docClient.put(params).promise();
        return {
            statusCode: 201,
            body: JSON.stringify({message: 'Successfully created item!'})
        }
    } catch (e) {
        return {error: "Unable to create product!", message: e.message}
    }
}