use array::ArrayTrait;
use result::ResultTrait;
use debug::PrintTrait;
use option::OptionTrait;
use traits::Into;
use starknet::ContractAddress;
use zeroable::Zeroable;
use starknet::contract_address::contract_address_const;


fn setup() -> felt252 {
    let totSupply: u256 = u256 {high: 1000000, low: 0};
    let mut deploy_data = ArrayTrait::new();
    deploy_data.append('Test');
    deploy_data.append('TST');
    deploy_data.append(18);
    deploy_data.append(totSupply.low.into());
    deploy_data.append(totSupply.high.into());
    deploy_data.append(0);
    let contract_address = deploy_contract('cairo_token', @deploy_data).unwrap();
    contract_address
}

#[test]
fn test_name(){
    let contract_address = setup();
    let res = call(contract_address, 'get_name', @ArrayTrait::new()).unwrap();
    assert(*res.at(0_u32) == 'Test', 'Invalid name')
}

#[test]
fn test_symbol() {
    let contract_address = setup();
    let res = call(contract_address, 'get_symbol', @ArrayTrait::new()).unwrap();
    assert(*res.at(0_u32) == 'TST', 'Invalid symbol')
}

#[test]
fn test_total_supply() {
    let contract_address = setup();
    let res = call(contract_address, 'get_totalSupply', @ArrayTrait::new()).unwrap();
    assert(*res.at(0_u32) == 1000000, 'Invalid total supply')
}

#[test]
fn test_balance_of() {
    let contract_address = setup();
    let mut params = ArrayTrait::new();
    params.append(Zeroable::zero());
    let res = call(contract_address, 'balanceOf', @params).unwrap();
    assert(*res.at(0_u32) == 1000000, 'Invalid total supply')
}

#[test]
fn test_mint() {
    let contract_address = setup();
    let mut params = ArrayTrait::new();
    params.append(1);
    params.append(200);
    invoke(contract_address, 'mint', @params).unwrap();
    let mut callparams = ArrayTrait::new();
    callparams.append(1);
    let res = call(contract_address, 'balanceOf', @callparams).unwrap();
    assert(*res.at(0_u32) == 200, 'Invalid balance');
    let totalSupply = call(contract_address, 'get_totalSupply', @ArrayTrait::new()).unwrap();
    assert(*totalSupply.at(0_u32) == 1000200, 'Invalid total supply');
}

#[test]
fn test_transfer() {
    let contract_address = setup();
    let mut params = ArrayTrait::new();
    params.append(1);
    params.append(300);
    invoke(contract_address, 'transfer', @params);
    let mut callparams = ArrayTrait::new();
    callparams.append(1);
    let res = call(contract_address, 'balanceOf', @callparams).unwrap();
    assert(*res.at(0_u32) == 300, 'Invalid balance');
}

#[test]
fn test_transferFrom() {
    let contract_address = setup();
    let mut approveParams = ArrayTrait::new();
    approveParams.append(1);
    approveParams.append(100);
    invoke(contract_address, 'approve', @approveParams);
    let mut allowanceCheckParams = ArrayTrait::new();
    allowanceCheckParams.append(Zeroable::zero());
    allowanceCheckParams.append(1);
    let allowanceRes = call(contract_address, 'get_allowance', @allowanceCheckParams).unwrap();
    assert(*allowanceRes.at(0_u32) == 100, 'Approval not set');
    let mut transferFromParams = ArrayTrait::new();
    transferFromParams.append(0);
    transferFromParams.append(2);
    transferFromParams.append(50);
    start_prank(1, contract_address);
    invoke(contract_address, 'transferFrom', @transferFromParams);
    let mut balanceparams = ArrayTrait::new();
    balanceparams.append(2);
    let res = call(contract_address, 'balanceOf', @balanceparams).unwrap();
    assert(*res.at(0_u32) == 50, 'Invalid balance');
}