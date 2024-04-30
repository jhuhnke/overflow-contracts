module escrow::utils {
    use std::vector::{Self}; 

    use sui::tx_context::{TxContext}; 
    use sui::object::{Self, UID, ID}; 
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap}; 
    use sui::transfer_policy::{Self as policy, TransferPolicy, TransferPolicyCap}; 
    use sui::coin::{Self}; 
    use sui::package::{Self, Publisher}; 

    const ENotPublisher: u64 = 0; 

    // ===== Structs =====
    struct OTW has drop {}
    
    struct Asset has key, store {
        id: UID
    }

    struct Unlocker<phantom T> has key, store {
        id: UID, 
        policy: TransferPolicy<T>, 
        cap: TransferPolicyCap<T>, 
    }

    // ===== Public Functions =====
    public fun get_kiosk(ctx: &mut TxContext): (Kiosk, KioskOwnerCap) {
        kiosk::new(ctx)
    }

    public fun return_publisher(publisher: Publisher) {
        package::burn_publisher(publisher)
    }

    public fun get_asset(ctx: &mut TxContext): (Asset, ID) {
        let uid = object::new(ctx); 
        let id = object::uid_to_inner(&uid); 
        (Asset { id: uid }, id)
    }

    public fun return_kiosk(kiosk: Kiosk, cap: KioskOwnerCap, ctx: &mut TxContext) {
        let profits = kiosk::close_and_withdraw(kiosk, cap, ctx); 
        coin::destroy_zero(profits); 
    }

    public fun return_assets(assets: vector<Asset>) {
        while (vector::length(&assets) >0 ) {
            let Asset { id } = vector::pop_back(&mut assets); 
            object::delete(id)
        }; 

        vector::destroy_empty(assets)
    }

    public fun return_policy(policy: TransferPolicy<Asset>, cap: TransferPolicyCap<Asset>, ctx: &mut TxContext) {
        let profits = policy::destroy_and_withdraw(policy, cap, ctx); 
        coin::destroy_zero(profits); 
    }

    public fun new_unlock<T: key + store>(
        publisher: &Publisher, 
        ctx: &mut TxContext
    ) : Unlocker<T> {
        let (policy, cap) = policy::new(publisher, ctx); 
        Unlocker { 
            cap, 
            policy, 
            id: object::new(ctx)
        }
    }

    public fun unlock<T: key + store> (
        self: &Unlocker<T>, 
        kiosk: &mut Kiosk, 
        cap: &KioskOwnerCap, 
        item_id: ID, 
        ctx: &mut TxContext
    ): T {
        let p_cap = kiosk::list_with_purchase_cap(kiosk, cap, item_id, 0, ctx); 
        let (item, request) = kiosk::purchase_with_cap(kiosk, p_cap, coin::zero(ctx)); 

        policy::confirm_request(&self.policy, request); 
        item 
    }

    public fun destroy<T: key +  store>(
        self: Unlocker<T>, 
        publisher: &Publisher, 
        ctx: &mut TxContext
    ) {
        assert!(package::from_package<T>(publisher), ENotPublisher); 

        let Unlocker {
            id, 
            policy, 
            cap
        } = self; 
        let zero = policy::destroy_and_withdraw(policy, cap, ctx); 
        coin::destroy_zero(zero); 
        object::delete(id);
    }

}