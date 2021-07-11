// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.7.0;

import './Token.sol';

contract DePoems {
  
  address public owner;
  struct Poem{
    mapping(uint => string) verses;
    uint versnumber;
    address creator;
    bool election;
    bool prop;
    uint min_worth;
    uint max_worth;
  }

  struct Proposals{
    string content;
    uint worth;
    uint votes;
    address payable proposer;
  }
  Token public t;
  Proposals[] tmp;
  mapping(address => mapping(uint => bool)) votes;
  mapping(uint => Poem) public Poems;
  mapping(uint => Proposals[]) public Propos;
  mapping(uint => address[]) voters;
  uint public poenumber;
  uint public actual = 9;
constructor(Token _t) public{
  owner = msg.sender;
  poenumber = 0;
  t = _t;
}

modifier poexists(uint _id){
  require(Poems[_id].versnumber >= 1);
  _;
}

modifier exists(uint _id, uint _vid){
  require(Poems[_id].versnumber >= _vid);
  _;
}

modifier iscreator(uint _id){
  require(Poems[_id].creator == msg.sender, "Not the Creator");
  _;
}

modifier eleactive(uint _id){
  require(Poems[_id].election, "not active");
  _;
}

modifier nodoublevote(uint _id){
  require(!votes[msg.sender][_id], "You already voted");
  _;
}

modifier propactive(uint _id){
  require(Poems[_id].prop, "The election has already started! You cannot submit proposals anymore");
  _;
}

modifier rightamount(uint _id, uint w){
  require((w >= Poems[_id].min_worth) && (w <= Poems[_id].max_worth), "Your pricing does not fit the expectations of the creator" );
  _;
}

function getvotecount(uint _id, uint _pid) public view returns(uint){
  return (Propos[_id][_pid-1].votes);

}
function sendprop(uint _id, string memory _con, uint w) public poexists(_id) propactive(_id) rightamount(_id, w){
   Proposals memory tmp;
   tmp.content = _con;
   tmp.votes = 0;
   tmp.worth = w;
   tmp.proposer = msg.sender;
   Propos[_id].push(tmp);
   
}

function startvote(uint _id) public iscreator(_id){
  require(Propos[_id].length > 0, "You cant start an election without any propositions");
  Poems[_id].election = true;
  Poems[_id].prop = false;
}
function delk(uint _id) public{
 
   delete Propos[_id];
 
}

function getbest(Proposals[] memory _prop) private returns(uint){
  uint top = 0;
  for(uint i = 0; i < _prop.length; i++){
    if(_prop[i].votes > _prop[top].votes){
      top = i;
    }
  }
  return top;
}

function elecdel(uint _id) private {
   address curr_address;
  for(uint i = 0; i < voters[_id].length; i++){
    curr_address = voters[_id][i];
    for(uint k = 1; k <= 10; k++)
    votes[curr_address][k] = false;
  }
}
function endvote(uint _id) public iscreator(_id) eleactive(_id){
  
  Poems[_id].election = false;
  Poems[_id].prop = true;
  uint top = getbest(Propos[_id]);
  require(t.balanceOf(msg.sender) >= Propos[_id][top].worth, "You don't have enough money");
  addvers(_id, Propos[_id][top].content);
 t.transferFrom(msg.sender,  Propos[_id][top].proposer, Propos[_id][top].worth);
 
  elecdel(_id);
 delk(_id);
  
}
function vote(uint _id, uint _pid) public eleactive(_id) nodoublevote(_id){
  Propos[_id][_pid-1].votes++;
  
  votes[msg.sender][_id] = true;
  voters[_id].push(msg.sender);
}


  function createPoe(string memory _firstvers, uint _min, uint _max) public {
    poenumber++;
    Poems[poenumber].verses[1] = _firstvers;
    Poems[poenumber].versnumber = 1;
    Poems[poenumber].creator = msg.sender;
    Poems[poenumber].prop = true;
    Poems[poenumber].min_worth = _min;
    Poems[poenumber].max_worth = _max;
    actual = Poems[poenumber].min_worth;
  }

  function addvers(uint _id, string memory _vers) private poexists(_id){
   Poems[_id].versnumber++;
   uint tmp = Poems[_id].versnumber;
   Poems[_id].verses[tmp] = _vers;
  }

  function getlength(uint _id) public view returns (uint number) {
    return Poems[_id].versnumber;
  }

  function getPoe(uint _id, uint _vid) public exists(_id, _vid) view returns (string memory) {
    return Poems[_id].verses[_vid];
  }

  function getProp(uint _id, uint _pid) public view returns (string memory) {
    return (Propos[_id][_pid-1].content);
  }

  function getlengthp(uint _id) public view returns(uint){
    return Propos[_id].length;
  }

  function getworth(uint _id, uint _pid) public view returns(uint){
    return Propos[_id][_pid].worth;
  }

  function getmax(uint _id) public view returns(uint){
    return Poems[_id].max_worth;
  }

  // Tokenspot

  function buytokens() public payable{
        t.transfer(msg.sender, msg.value*(100));
        
    }
}
