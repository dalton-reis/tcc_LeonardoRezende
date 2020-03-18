'use strict';
var AWS = require('aws-sdk');
const uuid = require('uuid');
const dynamoDB = new AWS.DynamoDB.DocumentClient();
const table = "VelocidadeMaxima";

module.exports.gravarVelocidadeMaxima = async (event) => {
  var latitude = event.queryStringParameters.latitude;
  var longitude = event.queryStringParameters.longitude;
  var velocidade = event.queryStringParameters.velocidade;
    
  var res1 = await add_velocidadeMaxima(""+latitude, ""+longitude, velocidade);
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: res1
    }, null, 2),
  }; 
}

async function add_velocidadeMaxima(aLatitude, aLongitude, aVelocidadeMaxima) {
    var dater =  new Date();
    var params = {
        Item : {
            "id" : uuid.v1(),
            "latitude" : aLatitude,
            "longitude" : aLongitude,
            "Velocidade" : aVelocidadeMaxima,
            // "input_type" : "1",
            "time_stamp_str" : dater.toISOString(),
            "time_stamp" : dater.getTime(),
            "time_stamp_hour" : dater.getHours()	
        },
        TableName : table
    };
    const r = dynamoDB.put(params).promise();
    return r;

}

