#[test_only]
#[allow(unused_function)]
module certificate::verifier_tests {
    // ===== Imports =====
    use sui::groth16::{Self, bn254}; 
    use std::vector; 

    use certificate::verifier::{
        do_verify, 
        do_just, 
        parse_pvk_from_vk
    };

    // ===== Verification Test Functions =====
    
    public entry fun verify_test() {
        do_verify(); 
    }

    public entry fun just_test() {
        do_just(); 
    }

    fun prepare_verifying_key_bn254_test() {
        let vk = x"53d75f472c207c7fcf6a34bc1e50cf0d7d2f983dd2230ffcaf280362d162c3871cae3e4f91b77eadaac316fe625e3764fb39af2bb5aa25007e9bc6b116f6f02f597ad7c28c4a33da5356e656dcef4660d7375973fe0d7b6dc642d51f16b6c8806030ca5b462a3502d560df7ff62b7f1215195233f688320de19e4b3a2a2cb6120ae49bcc0abbd3cbbf06b29b489edbf86e3b679f4e247464992145f468e3c08db41e5e09002a7170cb4cc56ae96b152d17b6b0d1b9333b41f2325c3c8a9d2e2df98f8e2315884fae52b3c6bb329df0359daac4eff4d2e7ce729078b10d79d42f02000000000000001dcc52e058148a622c51acfdee6e181252ec0e9717653f0be1faaf2a68222e0dd2ccf4e1e8b088efccfdb955a1ff4a0fd28ae2ccbe1a112449ddae8738fb40b0";
        let arr = groth16::pvk_to_bytes(groth16::prepare_verifying_key(&bn254(), &vk));

        let expected_vk_bytes = x"1dcc52e058148a622c51acfdee6e181252ec0e9717653f0be1faaf2a68222e0dd2ccf4e1e8b088efccfdb955a1ff4a0fd28ae2ccbe1a112449ddae8738fb40b0";
        let expected_alpha_bytes = x"61665b255f20b17bbd56b04a9e4d6bf596cb8d578ce5b2a9ccd498e26d394a3071485596cabce152f68889799f7f6b4e94d415c28e14a3aa609e389e344ae72778358ca908efe2349315bce79341c69623a14397b7fa47ae3fa31c6e41c2ee1b6ab50ef5434c1476d9894bc6afee68e0907b98aa8dfa3464cc9a122b247334064ff7615318b47b881cef4869f3dbfde38801475ae15244be1df58f55f71a5a01e28c8fa91fac886b97235fddb726dfc6a916483464ea130b6f82dc602e684b14f5ee655e510a0c1dd6f87b608718cd19d63a914f745a80c8016aa2c49883482aa28acd647cf9ce56446c0330fe6568bc03812b3bda44d804530abc67305f4914a509ecdc30f0b88b1a4a8b11e84856b333da3d86bb669a53dbfcde59511be60d8d5f7c79faa4910bf396ab04e7239d491e0a3bee177e6c9aac0ecbcd09ca850afcd46f25410849cefcfbdac828e7b057d4a732a373aad913d4b767897ba15d0bfcbcbb25bc5f2dae1ea59196ede9666a5c260f054b1a64977666af6a03076409";
        let expected_gamma_bytes = x"6030ca5b462a3502d560df7ff62b7f1215195233f688320de19e4b3a2a2cb6120ae49bcc0abbd3cbbf06b29b489edbf86e3b679f4e247464992145f468e3c00d";
        let expected_delta_bytes = x"b41e5e09002a7170cb4cc56ae96b152d17b6b0d1b9333b41f2325c3c8a9d2e2df98f8e2315884fae52b3c6bb329df0359daac4eff4d2e7ce729078b10d79d4af";

        let delta_bytes = vector::pop_back(&mut arr);
        assert!(delta_bytes == expected_delta_bytes, 0);

        let gamma_bytes = vector::pop_back(&mut arr);
        assert!(gamma_bytes == expected_gamma_bytes, 0);

        let alpha_bytes = vector::pop_back(&mut arr);
        assert!(alpha_bytes == expected_alpha_bytes, 0);

        let vk_bytes = vector::pop_back(&mut arr);
        assert!(vk_bytes == expected_vk_bytes, 0);


        parse_pvk_from_vk(vk);
    }

    // ===== Run Tests =====
    
    
}