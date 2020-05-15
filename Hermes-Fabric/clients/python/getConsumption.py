from hfc.fabric import Client as client_fabric
from tornado.platform.asyncio import AnyThreadEventLoopPolicy
import json
import asyncio
import sys
sys.path.insert(0, "..")

'''To solve a problem with asyncio'''
asyncio.set_event_loop_policy(AnyThreadEventLoopPolicy())


def getConsumption():
    loop = asyncio.get_event_loop()

    '''defines the chaincode version'''
    cc_version = "1.0"

    '''get the meter ID'''
    meter_id = sys.argv[1]

    '''instantiate the hyperledger fabric client with the network profile defined '''
    c_hlf = client_fabric(net_profile=sys.argv[2])

    '''get access to Fabric as Admin user'''
    admin = c_hlf.get_user('inmetro', 'Admin')

    '''the Fabric Python SDK do not read the channel configuration, we need to add it mannually'''
    c_hlf.new_channel('inmetro-channel')

    '''Query history'''
    response = loop.run_until_complete(c_hlf.chaincode_query(requestor=admin,channel_name='inmetro-channel',
                                                             peers=['peer0.inmetro'], args=[meter_id],
                                                             cc_name='fabHermes', cc_version=cc_version,
                                                             fcn='getConsumption'))

    '''print all the asset content'''
    print(response)

    '''response has the key/value asset struct in JSON format, so we use json library to load it'''
    data = json.loads(response)
    
    print(data)


if __name__ == "__main__":
    getConsumption()
