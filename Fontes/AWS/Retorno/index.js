var AWS = require('aws-sdk');
const uuid = require('uuid');
const dynamoDB = new AWS.DynamoDB.DocumentClient();
const table = VelocidadeMaxima;


module.exports.retornarvelocidades = async (event) = {
  var latitude = event.queryStringParameters.latitude;
  var longitude = event.queryStringParameters.longitude;
  
  var res2 = await read_velocidadeMaxima(+latitude, +longitude);
  
  return {
    statusCode 200,
    body JSON.stringify({
      message res2
    }, null, 2),
  };
  
}

async function read_velocidadeMaxima(aLatitude, aLongitude) {
    var params,params1;

    params = {
        TableName table,
        ProjectionExpression latitude, longitude, Velocidade,
        
        FilterExpression begins_with(#lat, latv) and begins_with(#lon, lonv),
        ExpressionAttributeNames {
            #lat latitude,
            #lon  longitude,
        },
        ExpressionAttributeValues {
             latv aLatitude,
             lonv  aLongitude
        }
    };
    params1 = {
        TableName table,
    };

	try {
	  const data = dynamoDB.scan(params).promise();
	  return data;
      return { statusCode 200, body JSON.stringify(data) };
	} catch (error) {
	  return {
	    statusCode 400,
	    error `Could not fetch ${error.stack}`
	  };
	}
}
