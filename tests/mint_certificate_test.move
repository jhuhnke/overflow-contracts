#[test_only]
module escrow::mint_cert_tests {
    use sui::test_scenario as ts; 
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use escrow::usdc::USDC; 
    use escrow::certificate::{Certificate};
    use escrow::certificate::{
        test_init, 
        mint,
        burn, 
        claim_certificate
    }; 

    const OWNER: address = @0x11; 
    const ALICE: address = @0xAA; 
    const MINT_AMOUNT: u64 = 50_000_000;
    
    fun init_test(): ts::Scenario {
        let scenario_val = ts::begin(OWNER); 
        let scenario = &mut scenario_val; 
        {
            test_init(ts::ctx(scenario)); 
            let payment: Coin<USDC> = coin::mint_for_testing(MINT_AMOUNT, ts::ctx(scenario));
            transfer::public_transfer(payment, ALICE);
        }; 
        scenario_val
    }

    // ===== Minting =====
    fun mint_test(age: bool, country: vector<u8>, scenario: &mut ts::Scenario) {
        ts::next_tx(scenario, ALICE); 
        {
            mint(age, country, ts::ctx(scenario)); 
        }; 
    }

    // ===== Burning =====
    fun burn_test(scenario: &mut ts::Scenario) {
        ts::next_tx(scenario, ALICE); 
        {
            let cert = ts::take_from_sender<Certificate>(scenario); 
            burn(cert); 
        }; 
    }

    // ===== Claiming =====
    fun claim_test(scenario: &mut ts::Scenario) {
        ts::next_tx(scenario, ALICE);
        {
            let payment = ts::take_from_sender<Coin<USDC>>(scenario);
            claim_certificate(true, b"United States", payment, 42, ts::ctx(scenario));
        };
    }

    // ===== Run Tests =====
    #[test]
    fun test_cert_mint() {
        let scenario_val = init_test(); 
        let scenario = &mut scenario_val; 
        mint_test(
            true, 
            b"United States", 
            scenario
        ); 
        ts::end(scenario_val); 
    }
  
    #[test]
    fun test_burn() {
        let scenario_val = init_test(); 
        let scenario = &mut scenario_val; 
        mint_test(
            true, 
            b"United States", 
            scenario
        ); 
        burn_test(scenario); 
        ts::end(scenario_val); 
    }

    #[test]
    fun test_claim() {
        let scenario_val = init_test();
        let scenario = &mut scenario_val;
        claim_test(scenario);
        ts::end(scenario_val);
    }
}