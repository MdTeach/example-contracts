pragma solidity ^0.6.4;

contract cityPoll {
    
    struct City {
        string cityName;
        uint256 vote;
    }


    mapping(uint256 => City) public cities; 
    mapping(address => bool) hasVoted; 
    
    address owner;
    uint256 public cityCount = 0; // number of city added
    
    constructor() public {
    
        //TODO set contract caller as owner
        owner = msg.sender;
    
        //TODO set some intitial cities.
        addCity("Kathmandhu");
        addCity("Pokhara");
        
    }
 
 
    function addCity(string memory cityName) public {
      //  TODO: add city to the CityStruct
      require(msg.sender == owner,"only owner user can add cities");
      
      
      City memory newCity = City({cityName:cityName, vote:0});
      cities[cityCount] = newCity;
      cityCount += 1;
    }
    
    function vote(uint256 id) public {
        //TODO Vote the selected city through cityID
        require(hasVoted[msg.sender] == false,"user have already voted");
        hasVoted[msg.sender] = true;
        cities[id].vote += 1;

    }
    
    function getCity(uint256 id) public view returns (string memory) {
        // TODO get the city details through cityID
        return cities[id].cityName;
    }
    
    function getVote(uint256 id) public view returns (uint256) {
        // TODO get the vote of the city with its ID
        return cities[id].vote;
    }
}

