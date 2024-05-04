#[test_only]
module certificate::mint_social_certificate_tests {
    use sui::test_scenario as ts; 
    use sui::transfer;
    use sui::coin::{Self, Coin}; 
    use certificate::social_certificate::{Certificate};
    use certificate::social_certificate::{
        test_init, 
        mint,
        burn, 
        claim_certificate
    }; 
    use sui::sui::SUI; 

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
    fun mint_test(platform: vector<u8>, username: vector<u8>, platform_id: vector<u8>, image_url: vector<u8>, scenario: &mut ts::Scenario) {
        ts::next_tx(scenario, ALICE); 
        {
            mint(platform, username, platform_id, image_url, ts::ctx(scenario)); 
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
            let payment = ts::take_from_sender<Coin<SUI>>(scenario);
            transfer::public_transfer(payment, OWNER);
            claim_certificate(b"Twitter", b"web3_analyst", b"3ijelkfjklew3", 42, b"www.image.com/image", ts::ctx(scenario));
        };
    }

    // ===== Run Tests =====
    #[test]
    fun test_cert_mint() {
        let scenario_val = init_test(); 
        let scenario = &mut scenario_val; 
        mint_test(
            b"Twitter", 
            b"web3_analyst", 
            b"jdfkljkrjl3",
            b"www.image.com/image",
            scenario
        ); 
        ts::end(scenario_val); 
    }
  
    #[test]
    fun test_burn() {
        let scenario_val = init_test(); 
        let scenario = &mut scenario_val; 
        mint_test(
            b"Twitter", 
            b"web3_analyst", 
            b"jdfkljkrjl3",
            b"www.image.com/image",
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