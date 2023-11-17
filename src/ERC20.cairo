//This line defines a new Starknet contract module named cairo_token
#[starknet::contract]
mod cairo_token{
    use starknet::ContractAddress; //The contract address is obviously address of the contract which is deployed on the starknet
    use starknet::get_caller_address; //Yes, the get_caller_address function in Cairo 1.0 is similar to msg.sender in Solidity
    trait <ContractState> {
        fn (ref self: ContractState, : ) -> ;
        fn (self: @ContractState, : ) -> ;
    }

    //In solidity we define the state varibales
    #[storage]
    struct storage {
        owner: ContractAddress,
        name: felt252,
        symbol: felt252,
        total_supply: u256,
        decimal: u8,
        balances: LegacyMap::<ContractAddress,u256>, //The LegacyMap is nothing but mapping in solidity
        allowance: LegacyMap::<(ContractAddress,ContractAddress),u256>,
    }

    #[constructor]
    fn constructor(ref self: ContractState,_owner:ContractAddress,_name: felt252,_symbol: felt252,_total_supply: u256,_decimal: u8) { 
        //ContractState: The self parameter is a reference to the contract's state (storage). ContractState is a type that represents the contract's state.
        //These lines are storing the input values _name, _symbol, _decimal, and _owner into their respective fields within the contract's storage.
        self.owner.write(_owner);
        self.name.write(_name);
        self.symbol.write(_symbol);
        self.total_supply.write(_total_supply);
        self.decimal.write(_decimal);
    }

    //The #[external(v0)] and #[generate_trait] decorators in Cairo 1.0 are used to define an interface for a smart contract and generate methods to interact with it, similar to how getter functions are used in Solidity.
    //#[external(v0)]: This attribute marks a function as an external entry point for the smart contract. It indicates that this function can be called from outside the contract, such as by other contracts or external entities.#[generate_trait]: This attribute specifies that the following implementation block will be generating an implementation for a specific trait.impl CairoTokenTraitImpl of CairoTokenTrait: It's generating an implementation of a trait named CairoTokenTraitImpl based on the CairoTokenTrait trait.
    #[external(v0)]
        #[generate_trait]
        impl CairoTokenTraitImpl of CairoTokenTrait{
            //Getter function to get the name
            fn name(self: @ContractState) -> felt252{
                self.name.read();
            }

            //Getter function to get the owner
            fn owner(self: @ContractState)-> ContractAddress {
                self.owner.read();
            }

            //Getter function of the symbol
            fn symbol(self: @ContractState) -> felt252 {
                self.owner.read();
            }

            //Getter function of totalSupply
            fn symbol(self: @ContractState) -> u256 {
                self.total_supply.read();
            }
        }

    //Writing the mint function
    fn mint(ref self:ContractState,to: ContractAddress,amount: u256) {
        //Check Only the owner can call the function
        assert(get_caller_address() == self.owner.read(),"Invalid caller");

        //When we mint new token we add them to the total supply
        let new_total_supply = self.total_supply.read() + amount;
        self.total_supply.write(new_total_supply);

        //Here it is updating the balance of user in the balances mapping
        let new_balance = self.balance.read(to) + amount;
        self.balance.write(to,new_balance);
    }

    //Returns the balanceOf the specified addrress 
    fn balanceOf(self: @ContractState,account: ContractAddress){
        self.balances.read(account);
    }

    //This function enables transferring tokens from the caller's address to a specified address. It utilizes the internal _transfer function to handle the actual transfer.
    fn transfer(ref self:ContractState,to: ContractAddress, amount: u256){
        //Transffering the amount from the person who calls the function 
        let caller:ContractAddress = get_caller_address();
        self._transfer(caller,to,amount);
    }

    //Returns the allowance granted by the owner to the spender
    fn allowance(self: @ContractState,owner: ContractAddress, spender: ContractAddress) -> u256 {
        //The @ symbol indicates that the function is not modifying the contract state
        self.allowance.read((owner,spender));
    }

    //This function lets the caller grant an allowance to another address (spender) to spend a certain amount of tokens from their balance.
    fn approve(ref self: ContractAddress,spender: ContractAddress,amount: u256){
        let caller = get_caller_address();

        //Checking the previous alloance and updating it 
        let mut prev_allowance:u256 = self.allowance.read((caller,spender));
        self.alloance.write((caller,spender),prev_allowance+amount);
    }

    //This function allows transferring tokens from a specified sender's address to another address, subject to an allowance. It checks the allowance, updates it, and uses _transfer to perform the transfer.
    fn TransferFrom(ref self:ContractState,sender:ContractAddress,to:ContractAddress,amount: u256) {
        let caller = get_caller_address();
        assert(self.allowances.read((sender, caller)) >= amount, 'No allowance');
        self.allowances.write((sender, caller), self.allowances.read((sender, caller)) - amount);
        self._transfer(sender, to, amount);
    }

    //Merko nahi malum kyaa hai ki yeh    
    #[generate_trait]
    impl PrivateFunctions of CairoTokenPrivateFunctionsTrait {

        fn _transfer(ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256) {
            assert(self.balances.read(sender) >= amount, 'Insufficient bal');
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            self.balances.write(sender, self.balances.read(sender) - amount)
        }

    }

}