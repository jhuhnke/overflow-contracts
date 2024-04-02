module escrow::social_certificate {
    use sui::object::{Self, ID, UID}; 
    use sui::tx_context::{Self, TxContext, sender}; 
    use sui::transfer; 
    use sui::event; 
    use sui::package; 
    use sui::display; 
    use std::string; 

    const CORRECT_PASSWORD: u8 = 42; 

    // ===== Structs =====
    struct Certificate has key {
        id: UID, 
        platform: string::String,
        username: string::String, 
        platform_id: string::String, 
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
    struct SOCIAL_CERTIFICATE has drop {}

    // ===== Initializer =====
    fun init(otw: SOCIAL_CERTIFICATE, ctx: &mut TxContext) {
        let keys = vector[
            string::utf8(b"image_url"),
            string::utf8(b"description"), 
            string::utf8(b"project_url"), 
        ]; 

        let values = vector[
            string::utf8(b"{image_url}"),
            string::utf8(b"This certificate verifies your ownership of a social media handle."), 
            string::utf8(b"zkrep.xyz")
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
    entry fun mint(platform: vector<u8>, username: vector<u8>, platform_id: vector<u8>, image_url: vector<u8>, ctx: &mut TxContext ) {
        let sender = tx_context::sender(ctx); 

        let cert = Certificate {
            id: object::new(ctx), 
            platform: string::utf8(platform), 
            username: string::utf8(username),
            platform_id: string::utf8(platform_id),  
            image_url: string::utf8(image_url), 
        }; 

        event::emit(MintCertificateEvent {
            object_id: object::uid_to_inner(&cert.id), 
            creator: sender
        }); 

        transfer::transfer(cert, sender) 
    }

    // ===== Burn Function =====
    entry fun burn(cert: Certificate) {
        let Certificate{ id, platform: _, username: _, platform_id: _, image_url: _, } = cert; 
        object::delete(id); 
    }

    // ===== Claim Function =====
    entry fun claim_certificate(
        platform: vector<u8>, 
        username: vector<u8>,
        platform_id: vector<u8>,  
        password: u8, 
        image_url: vector<u8>, 
        ctx: &mut TxContext
    ) {
        assert!(password == CORRECT_PASSWORD, 1002); 

        let sender = tx_context::sender(ctx); 
        let cert = Certificate {
            id: object::new(ctx),
            platform: string::utf8(platform),  
            username: string::utf8(username), 
            platform_id: string::utf8(platform_id), 
            image_url: string::utf8(image_url), 
        }; 

        event::emit(MintCertificateEvent {
            object_id: object::uid_to_inner(&cert.id), 
            creator: sender, 
        }); 

        transfer::transfer(cert, sender); 
    }

    // ===== Getters =====
    public fun platform(cert: &Certificate): &string::String {
        &cert.platform
    }

    public fun username(cert: &Certificate): &string::String {
        &cert.username
    }

    public fun platform_id(cert: &Certificate): &string::String {
        &cert.platform_id
    }

    public fun image_url(cert: &Certificate): &string::String {
        &cert.image_url
    }

    // ===== Test Init =====
    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx)
    }
}