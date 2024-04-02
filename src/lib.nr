// Adapted from: 
// https://github.com/debris/base58/blob/master/src/lib.rs
use dep::std;
mod base58;

struct Base58AddressDecode {
	prefix: u8,
	hash: [u8; 20],
	checksum: [u8; 4]
}

pub fn parse_address_bytes(decoded_address: BoundedVec<u8, 25>) -> Base58AddressDecode {
    let mut out = Base58AddressDecode { prefix: decoded_address.get(0), hash: [0; 20], checksum: [0; 4] };
    for i in 1..decoded_address.max_len() {
        if i < decoded_address.len() {
            if (i >= 1) & (i <= 20) {
                out.hash[i - 1] = decoded_address.get(i);
            } else {
                // i >= 21
                out.checksum[i - 21] = decoded_address.get(i);
            }
        }
    }
    out
}

// string encoder 
pub fn str_to_bvec<N>(string: str<N>) -> BoundedVec<u8, 90> {
    let mut out: BoundedVec<u8, 90> = BoundedVec::new();
    out.extend_from_array(string.as_bytes());
    out
}

pub fn decode_base58(encoded_string: BoundedVec<u8, 90>) -> BoundedVec<u8, 90> {
    base58::decode_base58(encoded_string)
}

pub fn decode_base58_address(encoded_address: BoundedVec<u8, 90>) -> Base58AddressDecode {
    let decoded_address_bytes = base58::decode_base58(encoded_address);
    let mut contrained_bytes: BoundedVec<u8, 25> = BoundedVec::new();
    contrained_bytes.extend_from_bounded_vec(decoded_address_bytes);
    parse_address_bytes(contrained_bytes)
}

unconstrained fn decoded_is_equal<N>(decoded: BoundedVec<u8, 90>, expected_content: [u8; N]) -> bool {
    let mut equal = true;
    if decoded.len() != expected_content.len() {
        equal = false;
    }
    for i in 0..N {
        if decoded.get(i) != expected_content[i] {
            equal = false;
        }
    }
    equal
}

#[test]
fn test_single_address_decode() {
    let mut data: BoundedVec<u8, 90> = str_to_bvec("188E5abxCSH6SyWvnaT5G5FEqVqAGBbKdj");
    let decode = decode_base58_address(data);
    assert(
        decode.hash
        == [78, 38, 181, 193, 68, 174, 181, 187, 224, 21, 187, 126, 252, 35, 72, 2, 75, 183, 21, 145]
    );
}

#[test]
fn test_from_base58_basic() {
    assert(decoded_is_equal(base58::decode_base58(str_to_bvec("")), []));
    assert(decoded_is_equal(base58::decode_base58(str_to_bvec("Z")), [32]));
    assert(decoded_is_equal(base58::decode_base58(str_to_bvec("n")), [45]));
    assert(decoded_is_equal(base58::decode_base58(str_to_bvec("q")), [48]));
    assert(decoded_is_equal(base58::decode_base58(str_to_bvec("r")), [49]));
    assert(decoded_is_equal(base58::decode_base58(str_to_bvec("z")), [57]));
    assert(decoded_is_equal(base58::decode_base58(str_to_bvec("4SU")), [45, 49]));
    assert(decoded_is_equal(base58::decode_base58(str_to_bvec("4k8")), [49, 49]));
    assert(decoded_is_equal(base58::decode_base58(str_to_bvec("ZiCa")), [97, 98, 99]));
    assert(
        decoded_is_equal(
            base58::decode_base58(str_to_bvec("3mJr7AoUXx2Wqd")),
            "1234598760".as_bytes()
        )
    );
    assert(
        decoded_is_equal(
            base58::decode_base58(str_to_bvec("3yxU3u1igY8WkgtjK92fbJQCd4BZiiT1v25f")),
            "abcdefghijklmnopqrstuvwxyz".as_bytes()
        )
    );
}

#[test(should_fail)]
fn test_from_base58_invalid_char_case_1() {
    let _ = base58::decode_base58(str_to_bvec("0"));
}

#[test(should_fail)]
fn test_from_base58_invalid_char_case_2() {
    let _ = base58::decode_base58(str_to_bvec("O"));
}

#[test(should_fail)]
fn test_from_base58_invalid_char_case_3() {
    let _ = base58::decode_base58(str_to_bvec("I"));
}

#[test(should_fail)]
fn test_from_base58_invalid_char_case_4() {
    let _ = base58::decode_base58(str_to_bvec("l"));
}

#[test(should_fail)]
fn test_from_base58_invalid_char_case_5() {
    let _ = base58::decode_base58(str_to_bvec("3mJr0"));
}

#[test(should_fail)]
fn test_from_base58_invalid_char_case_6() {
    let _ = base58::decode_base58(str_to_bvec("O3yxU"));
}

#[test(should_fail)]
fn test_from_base58_invalid_char_case_7() {
    let _ = base58::decode_base58(str_to_bvec("3sNI"));
}

#[test(should_fail)]
fn test_from_base58_invalid_char_case_8() {
    let _ = base58::decode_base58(str_to_bvec("4kl8"));
}

#[test(should_fail)]
fn test_from_base58_invalid_char_case_9() {
    let _ = base58::decode_base58(str_to_bvec("s!5<"));
}

#[test(should_fail)]
fn test_from_base58_invalid_char_case_10() {
    let _ = base58::decode_base58(str_to_bvec("t$@mX<*"));
}

#[test]
fn test_from_base58_initial_zeros() {
    assert(
        decoded_is_equal(
            base58::decode_base58(str_to_bvec("1ZiCa")),
            "\0abc".as_bytes()
        )
    );
    assert(
        decoded_is_equal(
            base58::decode_base58(str_to_bvec("11ZiCa")),
            "\0\0abc".as_bytes()
        )
    );
    assert(
        decoded_is_equal(
            base58::decode_base58(str_to_bvec("111ZiCa")),
            "\0\0\0abc".as_bytes()
        )
    );
    assert(
        decoded_is_equal(
            base58::decode_base58(str_to_bvec("1111ZiCa")),
            "\0\0\0\0abc".as_bytes()
        )
    );
}

