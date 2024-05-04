module certificate::proof_policy {
    use sui::transfer_policy::{
        Self as policy, 
        TransferPolicy, 
        TransferRequest
    }; 

    use certificate::verifier; 

    const ERuleNotFound: u64 = 0; 
    const EIsNotVerified: u64 = 1; 

    // ===== Structs =====
    struct Rule has drop {}

    // ===== Public Functions =====
    public fun prove<T>(
        policy: &TransferPolicy<T>, 
        request: &mut TransferRequest<T>, 
        vk_bytes: vector<u8>, 
        public_inputs_bytes: vector<u8>, 
        proof_points_bytes: vector<u8>, 
    ) {
        assert!(policy::has_rule<T, Rule>(policy), ERuleNotFound); 
        let isVerified = verifier::verify_proof(vk_bytes, public_inputs_bytes, proof_points_bytes); 
        assert!(isVerified == true, EIsNotVerified); 
        policy::add_receipt(Rule {}, request); 
    }
}