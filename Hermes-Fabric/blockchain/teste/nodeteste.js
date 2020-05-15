var hfc = require('fabric-client');
//hfc.initCredentialStores().then(nothing);
hfc.setUserContext({username:'admin', password:'adminpw'});

//hfc.setLogger(logger);
hfc.loadFromConfig('connection-inmetro.yaml');


var msg = (hfc.loadFromConfig('connection-inmetro.yaml'))
console.log(msg)