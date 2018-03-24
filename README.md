# DeliveryGuy

Makes requests based on a JSON file. See my blog page [here](https://mramirogonzalez.github.io/Using-DeliveryGuy/) for more infos.

Returns 1 when all the expected response codes match.

## Installation
You need to have Erlang & Elixir installed
```
# Setup project
git clone https://github.com/mRamiroGonzalez/DeliveryGuy.git
cd DeliveryGuy 
mix escript.build

# With the JSON server (if you don't have a server to test)
json-server --watch test/db.json
./deliveryguy --source exampleRequests/will-success.json

# Or use your own server
./deliveryguy --source yourOwnRequests.json

```

## TODO:
- handle errors (currently throws an exception)
- add tests with failure cases
- add more ways to validate the response (only response code now)
- ~~handle conenexion errors~~
- handle timeout when the server does not respond
- ~~store variable between routes / groups~~
- ~~add feedback to know which request failed~~
