const AWS = require('aws-sdk');
const eventBridge = new AWS.EventBridge()

module.exports.handler = async (event) => {

    event.Records.forEach(it => {
        console.log("Product " + it.eventName + " => " + JSON.stringify(it.dynamodb))

        const params = {
            Entries: [
                {
                    Detail: JSON.stringify({
                        "payload": it,
                        "state": it.eventName
                    }),
                    DetailType: 'Message',
                    EventBusName: 'default',
                    Source: 'dynamodb.event',
                    Time: new Date()
                }
            ]
        }
        // Publish to EventBridge
        const result = await eventBridge.putEvents(params).promise()
        console.log(result)
    })
}