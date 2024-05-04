module escrow::identity_certificate {
    use sui::object::{Self, ID, UID}; 
    use sui::tx_context::{Self, TxContext, sender};
    use sui::transfer;
    use sui::event; 
    use sui::package; 
    use sui::display;
    use std::string;

    // ===== Check Decimals of USDC =====
    const CORRECT_PASSWORD: u8 = 42; 

    // ===== Structs =====
    struct Certificate has key {
        id: UID, 
        age: bool, 
        country: string::String, 
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
    struct IDENTITY_CERTIFICATE has drop {}

    // ===== Initializer =====
    fun init(otw: IDENTITY_CERTIFICATE, ctx: &mut TxContext) {
        let keys = vector[
            string::utf8(b"image_url"),
            string::utf8(b"description"), 
            string::utf8(b"project_url"),  
        ]; 

        let values = vector[
            string::utf8(b"{image_url}"),
            string::utf8(b"This certificate verifies your residency and age on-chain."), 
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
    entry fun mint(age: bool, country: vector<u8>, image_url: vector<u8>, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx); 

        let cert = Certificate {
            id: object::new(ctx), 
            age: age, 
            country: string::utf8(country), 
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
        let Certificate { id, age: _, country: _, image_url: _, } = cert; 
        object::delete(id); 
    }

    // ===== Claim Function =====
    entry fun claim_certificate(
            age: bool, 
            country: vector<u8>, 
            password: u8,
            image_url: vector<u8>,
            ctx: &mut TxContext
        ) {
        assert!(password == CORRECT_PASSWORD, 1002); 

        let sender = tx_context::sender(ctx);
        let cert = Certificate {
            id: object::new(ctx),
            age: age,
            country: string::utf8(country),
            image_url: string::utf8(image_url),
        };

        event::emit(MintCertificateEvent {
            object_id: object::uid_to_inner(&cert.id),
            creator: sender,
        });

        transfer::transfer(cert, sender);
    }

    // ===== Getters =====
    public fun age(cert: &Certificate): &bool {
        &cert.age
    }
    
    public fun country(cert: &Certificate): &string::String {
        &cert.country
    }

    public fun image_url(cert: &Certificate): &string::String {
        &cert.image_url
    }

    // ===== Test Init =====
    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(IDENTITY_CERTIFICATE {}, ctx)
    }
}