#[test_only]
module certificate::mint_credit_score_tests {
    use sui::test_scenario as ts; 
    use sui::transfer;
    use sui::sui::SUI; 
    use sui::coin::{Self};
    use certificate::credit_score::{Certificate};
    use certificate::credit_score::{
        test_init, 
        mint,
        burn
    }; 

    const OWNER: address = @0x11; 
    const ALICE: address = @0xAA; 
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

    // ===== Minting =====
    fun mint_test(image_url: vector<u8>, scenario: &mut ts::Scenario) {
        ts::next_tx(scenario, ALICE); 
        {
            mint(image_url, ts::ctx(scenario)); 
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

    // ===== Run Tests =====
    #[test]
    fun test_cert_mint() {
        let scenario_val = init_test(); 
        let scenario = &mut scenario_val; 
        mint_test(
            b"www.image.com/cert", 
            scenario
        ); 
        ts::end(scenario_val); 
    }
  
    #[test]
    fun test_burn() {
        let scenario_val = init_test(); 
        let scenario = &mut scenario_val; 
        mint_test(
            b"www.image.com/cert", 
            scenario
        ); 
        burn_test(scenario); 
        ts::end(scenario_val); 
    }
}