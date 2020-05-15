import asyncio
from hfc.fabric_ca.caservice import ca_service
from hfc.fabric import Client as client_fabric
from tornado.platform.asyncio import AnyThreadEventLoopPolicy
import json
cc_version = "1.0"
#asyncio.set_event_loop_policy(AnyThreadEventLoopPolicy())
def testeinsert():


    c_hlf = client_fabric(net_profile="ptb-network-tls.json")


    admin = c_hlf.get_user('inmetro.com', 'Admin')


    # Make the client know there is a channel in the network
    c_hlf.new_channel('mychannel')

    loop = asyncio.get_event_loop()

    data = "{\"id\":\"666\",\"sensor\":\"DHT\",\"value\":24.7,\"Timestamp\":0.75,\"location\":\"laboratorio\",\"physicalQuantity\":\"Temperatura\"}"
    # parsed = json.loads(data)
    # print(json.dumps(parsed, indent=4, sort_keys=True))
    id ='666'

    #The response should be true if succeed
    response = loop.run_until_complete(c_hlf.chaincode_invoke(
                requestor=admin,
                channel_name='mychannel',
                peers=['peer0.inmetro.com'],
                args=[id, data],
                cc_name='mycc',
                cc_version=cc_version,
                fcn='insertMeasurement'
                ))

    #response = loop.run_until_complete(c_hlf.chaincode_invoke(
    #           requestor=admin,
    #           channel_name='mychannel',
    #           peers=['peer0.inmetro.com'],
    #           args=[id],
    #           cc_name='mycc',
    #           cc_version=cc_version,
    #           fcn='queryHistory'
    #           ))
    print(response)
    return response

if __name__ == "__main__":
    testeinsert()
