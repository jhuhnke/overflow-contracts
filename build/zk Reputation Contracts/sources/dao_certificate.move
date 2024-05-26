module certificate::dao_certificate {
    use sui::object::{Self, ID, UID}; 
    use sui::tx_context::{Self, TxContext, sender};
    use sui::transfer;
    use sui::event; 
    use sui::display;
    use sui::package;
    use sui::dynamic_object_field as ofield;
    use std::string;

    // ===== Struct =====
    struct DaoOwnerCert has key, store {
        id: UID, 
        name: string::String, 
        description: string::String, 
        webpage_url: string::String, 
        image_url: string::String, 
    }

    struct MintDaoOwnerCertEvent has copy, drop {
        object_id: ID, 
        owner: address
    }

    struct RoleCert has key, store {
        id: UID, 
        role: string::String,
        user: address
    }

    struct MintRoleCertEvent has copy, drop {
        object_id: ID, 
        owner: address
    }

    struct Ownership has key {
        id: UID, 
    }

    // ===== Constants =====
    //const ENoRole: u64 = 1; 

    // ===== OTW =====
    struct DAO_CERTIFICATE has drop {}

    // ===== Initializer =====
    fun init(otw: DAO_CERTIFICATE, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx); 

        let keys = vector[
            string::utf8(b"image_url"), 
            string::utf8(b"DAO_Webpage")
        ];

        let values = vector[
            string::utf8(b"{image_url}"), 
            string::utf8(b"zkrep.xyz"),
        ];

        let display = display::new_with_fields<DaoOwnerCert>(
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

    // ===== Create DAO =====
    entry fun create_dao(
        name: vector<u8>, 
        description: vector<u8>, 
        webpage_url: vector<u8>, 
        image_url: vector<u8>, 
        ctx: &mut TxContext
        ) {

        let sender  = tx_context::sender(ctx); 

        let dao = DaoOwnerCert {
            id: object::new(ctx), 
            name: string::utf8(name), 
            description: string::utf8(description), 
            webpage_url: string::utf8(webpage_url), 
            image_url: string::utf8(image_url), 
        };

        event::emit(MintDaoOwnerCertEvent {
            object_id: object::uid_to_inner(&dao.id), 
            owner: sender
        }); 

        transfer::transfer(dao, sender); 
    }

    // ===== Grant Role =====
    entry fun grant_role(
        ownercert: &mut DaoOwnerCert, 
        user: address, 
        role: vector<u8>, 
        ctx: &mut TxContext
        ) {

            let sender = tx_context::sender(ctx); 

            let rolecert = RoleCert {
                id: object::new(ctx), 
                role: string::utf8(role),
                user: user
            };

            event::emit(MintRoleCertEvent {
                object_id: object::uid_to_inner(&rolecert.id), 
                owner: sender
            });

            ofield::add(&mut ownercert.id, user, rolecert);

    }

    // ===== Change Role =====
    entry fun change_role(parent: &mut DaoOwnerCert, child_name: address, new_role: vector<u8>) {
        mutate(ofield::borrow_mut<address, RoleCert>(
            &mut parent.id, 
            child_name, 
        ), 
        new_role
        ); 
    }

    // ===== Change Role Directly =====
    entry fun mutate(child: &mut RoleCert, new_role: vector<u8>) {
        child.role = string::utf8(new_role); 
    }

    // ===== Burn DAO Ownership =====
    entry fun burn_dao(dao: DaoOwnerCert) {
        let DaoOwnerCert { id, name: _, description: _, webpage_url: _, image_url: _} = dao; 
        object::delete(id); 
    }

    // ===== Getters =====
    public fun dao_name(nft: &DaoOwnerCert): &string::String {
        &nft.name
    }

    public fun dao_description(nft: &DaoOwnerCert): &string::String {
        &nft.description
    }

    public fun dao_webpage(nft: &DaoOwnerCert): string::String {
        nft.webpage_url 
    }

    public fun dao_image(nft: &DaoOwnerCert): string::String {
        nft.image_url
    }

    // ===== Test Init ======
    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(DAO_CERTIFICATE {}, ctx)
    }
}