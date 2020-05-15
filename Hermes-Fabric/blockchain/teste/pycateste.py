from hfc.fabric_ca.caservice import ca_service

def testeinsert():
    cacli = ca_service(target="https://127.0.0.1:7054")

    identityService = cacli.newIdentityService()

    print(identityService)

    admin = cacli.enroll("admin", "pass")  # now local will have the admin user


if __name__ == "__main__":
    testeinsert()
