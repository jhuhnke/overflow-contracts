module escrow::helpers {
    use sui::object::{Self, ID}; 
    use sui::transfer_policy::{Self, TransferPolicy, TransferRequest}; 
    use sui::event; 

    use escrow::proof_policy; 

    // ===== Structs =====
    
    struct LogObjectIdEvent has copy, drop {
        object_id: ID,
    }

    // ===== Public Functions =====

    public fun log_object_id<T: key>(
        object: &T,
    ) {
        let object_id = object::id(object);
        event::emit(LogObjectIdEvent {
            object_id,
        });
    }

    public fun prove_and_claim<T>(
        policy: &mut TransferPolicy<T>,
        request: TransferRequest<T>,
        vk_bytes: vector<u8>,
        public_inputs_bytes: vector<u8>,
        proof_points_bytes: vector<u8>,
    ) {
        proof_policy::prove<T>(
            policy,
            &mut request,
            vk_bytes,
            public_inputs_bytes,
            proof_points_bytes,
        );

        transfer_policy::confirm_request<T>(
            policy,
            request,
        );
    }
}