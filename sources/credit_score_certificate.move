module escrow::credit_score {
    use sui::object::{Self, ID, UID}; 
    use sui::tx_context::{Self, TxContext, sender}; 
    use sui::transfer; 
    use sui::event; 
    use sui::package; 
    use sui::display; 
    use std::string; 

    // ===== Structs =====
    struct Certificate has key {
        id: UID, 
        image_url: string::String, 
    }

    struct MintCertificateEvent has copy, drop {
        object_id: ID, 
        creator: address
    }

    struct Ownership has key {
        id: UID
    }

    // ===== OTW =====
    struct CREDIT_SCORE has drop {}

    // ===== Initializer =====
    fun init(otw: CREDIT_SCORE, ctx: &mut TxContext) {
        let keys = vector[
            string::utf8(b"image_url"), 
            string::utf8(b"dscription"), 
            string::utf8(b"project_url"), 
        ]; 

        let values = vector[
            string::utf8(b"{image_url}"), 
            string::utf8(b"{description}"), 
            string::utf8(b"{webpage_url}")
        ]; 

        let publisher = package::claim(otw, ctx); 

        let display = display::new_with_fields<Certificate>(
            &publisher, keys, values, ctx
        ); 

        let ownership = Ownership {
            id: object::new(ctx)
        }; 

        display::update_version(&mut display); 

        transfer::public_transfer(publisher, sender(ctx)); 
        transfer::public_transfer(display, sender(ctx)); 

        transfer::transfer(ownership, tx_context::sender(ctx)); 
    }

    // ===== Minting Function =====
    entry fun mint(image_url: vector<u8>, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx); 

        let cert = Certificate {
            id: object::new(ctx), 
            image_url: string::utf8(image_url)
        }; 

        event::emit(MintCertificateEvent {
            object_id: object::uid_to_inner(&cert.id), 
            creator: sender
        }); 

        transfer::transfer(cert, sender)
    }

    // ===== Burn Function =====
    entry fun burn(cert: Certificate) {
        let Certificate { id, image_url: _, } = cert; 
        object::delete(id); 
    }

    // ===== Getters =====
    public fun image_url(cert: &Certificate): &string::String {
        &cert.image_url
    }

    // ===== Test Init =====
    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(CREDIT_SCORE {}, ctx)
    }
}