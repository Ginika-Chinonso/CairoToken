#[contract]
mod cairo_token {

    use starknet::ContractAddress;
    use starknet::get_caller_address;

    struct Storage {
        owner: ContractAddress,
        name: felt252,
        symbol: felt252,
        total_supply: u256,
        decimal: u8,
        balances: LegacyMap::<ContractAddress, u256>,
        allowances: LegacyMap::<(ContractAddress, ContractAddress), u256>, 
    }

    #[constructor]
    fn constructor(_name: felt252, _symbol: felt252, _decimal: u8, _total_supply: u256, _owner: ContractAddress) {

        name::write(_name);
        symbol::write(_symbol);
        decimal::write(_decimal);
        owner::write(_owner);

        mint(_owner, _total_supply)
    }


    #[view]
    fn get_name() -> felt252 {
        name::read()
    }

    #[view]
    fn get_owner() -> ContractAddress {
        owner::read()
    }

    #[view]
    fn get_symbol() -> felt252 {
        symbol::read()
    }

    #[view]
    fn get_totalSupply() -> u256 {
        total_supply::read()
    }

    #[external]
    fn mint(to: ContractAddress, amount: u256) {
        assert(get_caller_address() == owner::read(), 'Invalid caller');
        let new_total_supply = total_supply::read() + amount;
        total_supply::write(new_total_supply);
        let new_balance = balances::read(to) + amount;
        balances::write(to, new_balance);
    }

    #[external]
    fn transfer(to: ContractAddress, amount: u256){
        let caller: ContractAddress = get_caller_address();
        _transfer(caller, to, amount);
    }

    #[internal]
    fn _transfer(sender: ContractAddress, recipient: ContractAddress, amount: u256) {
        assert(balances::read(sender) >= amount, 'Insufficient bal');
        balances::write(recipient, balances::read(recipient) + amount);
        balances::write(sender, balances::read(sender) - amount);
    }


    #[external]
    fn transferFrom(sender: ContractAddress, to: ContractAddress, amount: u256){
        let caller = get_caller_address();
        assert(allowances::read((sender, caller)) >= amount, 'No allowance');
        allowances::write((sender, caller), allowances::read((sender, caller)) - amount);
        _transfer(sender, to, amount);
    }


    #[external]
    fn approve(spender: ContractAddress, amount: u256) {
        let caller: ContractAddress = get_caller_address();
        let mut prev_allowance: u256 = allowances::read((caller, spender));
        allowances::write((caller, spender), prev_allowance + amount);
    }


    #[external]
    fn get_allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
        allowances::read((owner, spender))
    }

    #[external]
    fn balanceOf(account: ContractAddress) -> u256 {
        balances::read(account)
    }

}