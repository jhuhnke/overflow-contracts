#[test_only]
#[allow(unused_use)]
module certificate::mint_dao_certificate_tests {
    use sui::test_scenario as ts; 
    use sui::transfer;
    use sui::sui::SUI; 
    use sui::coin::{Self, Coin}; 
    use certificate::dao_certificate::{
        DaoOwnerCert, 
        RoleCert
    }; 
    use certificate::dao_certificate::{
        test_init, 
        create_dao, 
        grant_role, 
        change_role, 
        burn_dao
    }; 

    const OWNER: address = @0x11; 
    const ALICE: address = @0xAA;
    const BOB: address = @0xBB;
    const MINT_AMOUNT: u64 = 50_000_000; 

    fun init_test(): ts::Scenario {
        let scenario_val = ts::begin(OWNER); 
        let scenario = &mut scenario_val; 
        {
            test_init(ts::ctx(scenario)); 
            let payment = coin::mint_for_testing<SUI>(MINT_AMOUNT, ts::ctx(scenario)); 
            transfer::public_transfer(payment, ALICE); 
        };
        scenario_val
    }

    // ===== Create DAO =====
    fun create_test(
        name: vector<u8>, 
        description: vector<u8>, 
        webpage_url: vector<u8>, 
        image_url: vector<u8>, 
        scenario: &mut ts::Scenario
    ){
        ts::next_tx(scenario, ALICE); 
        {
            create_dao(name, description, webpage_url, image_url, ts::ctx(scenario)); 
        }; 
    }

    // ===== Burn DAO =====
    fun burn_test(
        scenario: &mut ts::Scenario
    ){
        ts::next_tx(scenario, ALICE); 
        {
            let ownercert = ts::take_from_sender<DaoOwnerCert>(scenario); 
            burn_dao(ownercert); 
        }; 
    }

    // ===== Grant Role =====
    fun grant_test(
        user: address, 
        role: vector<u8>, 
        scenario: &mut ts::Scenario
    ) {
        ts::next_tx(scenario, ALICE); 
        {
            let ownercert = ts::take_from_sender<DaoOwnerCert>(scenario); 
            grant_role(&mut ownercert, user, role, ts::ctx(scenario)); 
            ts::return_to_sender(scenario, ownercert); 
        }; 
    }

    // ===== Change Role =====
    fun change_test(
        child_name: address, 
        new_role: vector<u8>, 
        scenario: &mut ts::Scenario
    ) {
        ts::next_tx(scenario, ALICE); 
        {
            let ownercert = ts::take_from_sender<DaoOwnerCert>(scenario); 
            change_role(&mut ownercert, child_name, new_role); 
            ts::return_to_sender(scenario, ownercert); 
        }; 
    }

    // ===== Run Tests =====
    #[test]
    fun test_cert_create_dao() {
        let scenario_val = init_test(); 
        let scenario = &mut scenario_val; 
        create_test(
            b"Best DAO ever", 
            b"Join or take the L bozo", 
            b"www.bestdaoever.io", 
            b"www.image.com/dao", 
            scenario
        ); 
        ts::end(scenario_val); 
    }

    #[test]
    fun test_cert_grant_role() {
        let scenario_val = init_test(); 
        let scenario = &mut scenario_val; 
        create_test(
            b"Best DAO ever", 
            b"Join or take the L bozo", 
            b"www.bestdaoever.io", 
            b"www.image.com/dao", 
            scenario
        ); 
        grant_test(
            BOB, 
            b"developer",
            scenario
        ); 
        burn_test(
            scenario
        ); 
        ts::end(scenario_val); 
    }

    #[test]
    fun test_cert_change_role() {
        let scenario_val = init_test(); 
        let scenario = &mut scenario_val; 
        create_test(
            b"Best DAO ever", 
            b"Join or take the L bozo", 
            b"www.bestdaoever.io", 
            b"www.image.com/dao", 
            scenario
        ); 
        grant_test(
            BOB, 
            b"developer",
            scenario
        ); 
        change_test(
            BOB, 
            b"exit liquidity", 
            scenario
        ); 
        burn_test(
            scenario
        ); 
        ts::end(scenario_val); 
    }
    
}