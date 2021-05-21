pragma solidity ^0.5.0;

/*
    The EventTickets contract keeps track of the details and ticket sales of one event.
*/

contract EventTickets {

    address payable owner;
    uint TICKET_PRICE = 100 wei;
   
    struct Event{
        string description;
        string website;
        uint totalTickets;
        uint sales;
        mapping(address => uint) buyers;
        bool isOpen;
    }
    Event myEvent;
   
    event LogBuyTickets(address purchaser, uint num_ticket);
    event LogGetRefund(address requester, uint num_ticket);
    event LogEndSale(address owner, uint balance_transfer);
    
    
    modifier OnlyOwner {
        require(owner == msg.sender,"only owner can execute this contract");
        _;
    }
    
    
    constructor(string memory _description, string memory _url, uint _num_tickets)public{
        owner = msg.sender;
        myEvent.website = _url;
        myEvent.totalTickets = _num_tickets;
        myEvent.description = _description;
        
        myEvent.isOpen = true;
    }

   function readEvent()
        public view
        returns(string memory, string memory, uint, uint, bool){
        string memory description = myEvent.description;
        string memory website = myEvent.website;
        uint totalTickets = myEvent.totalTickets;
        uint sales = myEvent.sales;
        bool isOpen = myEvent.isOpen;
        
        return (description, website, totalTickets, sales, isOpen);
    }

    function getBuyerTicketCount(address addrs) public view returns (uint){
        return myEvent.buyers[addrs];
    }

    function buyTickets(uint _num_tickets) public payable returns(bool){
        require(myEvent.isOpen == true, "event is closed");
        uint remainingTickets = myEvent.totalTickets - myEvent.sales;
        require(remainingTickets >= _num_tickets, "tickets are out of supply");
        uint ticketPrice = _num_tickets * TICKET_PRICE;
        require(msg.value >= ticketPrice, "insufficent amt sent");
        
        // add tickets to sender account
        myEvent.buyers[msg.sender] += _num_tickets;
        myEvent.sales += _num_tickets;
        
        // refund surplus
        if(msg.value > ticketPrice){
            uint surplus = msg.value - ticketPrice;
            msg.sender.transfer(surplus);
        }
        
        emit LogBuyTickets(msg.sender, _num_tickets);
        return true;
    }
    
    function getRefund() public returns(bool){
        uint num_ticket = myEvent.buyers[msg.sender];
        require(num_ticket > 0, "The address don't have any tickets");
        
        // refund
        uint refundAmt = num_ticket * TICKET_PRICE;
        msg.sender.transfer(refundAmt);
        delete myEvent.buyers[msg.sender];
        
        myEvent.sales -= num_ticket;
        
        emit LogGetRefund(msg.sender, num_ticket);
        return true;
    }

    
    function endSale() public OnlyOwner returns(bool){
        myEvent.isOpen = false;
        owner.transfer(myEvent.sales * TICKET_PRICE);
        
        emit LogEndSale(owner, myEvent.sales * TICKET_PRICE);
        return true;
    }
}