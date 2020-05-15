import asyncio
from hfc.fabric_ca.caservice import ca_service
from hfc.fabric import Client
from tornado.platform.asyncio import AnyThreadEventLoopPolicy
import json

#asyncio.set_event_loop_policy(AnyThreadEventLoopPolicy())
def testeinsert():
    loop = asyncio.get_event_loop()

    cli = Client(net_profile="testeconnection.json")

    print(cli.organizations)  # orgs in the network
    print(cli.peers)  # peers in the network
    print(cli.orderers)  # orderers in the network
    print(cli.CAs)  # ca nodes in the network, TODO


    org1_admin = cli.get_user(org_name='Inmetro', name='Admin')




    print('teste1')
    cc_version = "1.0"

    # Make the client know there is a channel in the network
    cli.new_channel('mychannel')

    data = "{\"id\":\"666\",\"sensor\":\"DHT\",\"value\":24.7,\"Timestamp\":0.75,\"location\":\"laboratorio\",\"physicalQuantity\":\"Temperatura\"}"
    # parsed = json.loads(data)
    # print(json.dumps(parsed, indent=4, sort_keys=True))
    id ='666'

    #The response should be true if succeed
    response = loop.run_until_complete(cli.chaincode_invoke(
               requestor=org1_admin,
               channel_name='mychannel',
               peers=['peer0.inmetro.com'],
               args=[id, data],
               cc_name='mycc',
               cc_version=cc_version,
               fcn='insertMeasurement',
               cc_pattern=None
               ))
    print(response)
    return 'Ok, deu certo caceta'

if __name__ == "__main__":
    testeinsert()
