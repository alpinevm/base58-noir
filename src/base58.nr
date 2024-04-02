use dep::std;

global B58_DIGITS_MAP: [i8; 128] = [
	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
	-1, 0, 1, 2, 3, 4, 5, 6, 7, 8,-1,-1,-1,-1,-1,-1,
	-1, 9,10,11,12,13,14,15,16,-1,17,18,19,20,21,-1,
	22,23,24,25,26,27,28,29,30,31,32,-1,-1,-1,-1,-1,
	-1,33,34,35,36,37,38,39,40,41,42,43,-1,44,45,46,
	47,48,49,50,51,52,53,54,55,56,57,-1,-1,-1,-1,-1,
];

pub(crate) fn decode_base58(b58: BoundedVec<u8, 90>) -> BoundedVec<u8, 90> {
    let mut bin: [u8; 132] = [0; 132];
    // (132 + 3) / 4
    let mut out: [u32; 33]  = [0; 33];
    let bytesleft = (bin.len() % 4) as u8;

    let mut zeromask: u32 = 0xffffffff as u32 << (bytesleft as u32 * 8);
    if bytesleft == 0 {
        zeromask = 0;
    }

    let mut zcount: u8 = 0;
    let mut counting: bool = true;
    // if it's a string with only 1s in it
    for j in 0..b58.max_len() {
        if j < b58.len() {
            // "1" as u8
            if counting & (b58.get(j) == 49) {
                zcount += 1;
            } else {
                counting = false;
            }
        }
    }

    let mut i_count: u8 = zcount;
    for _ in 0..b58.max_len() {
        if i_count as u8 < b58.len() as u8 {
            assert(b58.get(i_count as u64) & 0x80 == 0, "base58::InvalidBase58Character");
            assert(B58_DIGITS_MAP[b58.get(i_count as u64)] != -1, "base58::InvalidBase58Character");
            let mut c = B58_DIGITS_MAP[b58.get(i_count as u64)] as u64;
            let mut j = out.len();
            for _ in 0..out.len() {
                if j != 0 {
                    j -= 1;
                    let t = out[j] as u64 * 58 + c;
                    c = (t & 0x3f00000000) >> 32;
                    out[j] = (t & 0xffffffff) as u32;
                }
            }
            assert(c == 0, "base58::InvalidBase58Length");
            assert((out[0] & zeromask) == 0, "base58::InvalidBase58Length");
            i_count += 1;
        }
    }

    let mut i = 1;
    let mut j = 0;

    if bytesleft == 3 {
        bin[0] = ((out[0] & 0xff0000) >> 16) as u8;
    } else if bytesleft == 2 {
        bin[0] = ((out[0] & 0xff00) >> 8) as u8;
    } else if bytesleft == 1 {
        j = 1;
        bin[0] = (out[0] & 0xff) as u8;
    } else {
        i = 0;
    }

    for _ in 0..90 {
        if j < out.len() {
            bin[i] = ((out[j] >> 0x18) & 0xff) as u8;
            bin[i + 1] = ((out[j] >> 0x10) & 0xff) as u8;
            bin[i + 2] = ((out[j] >> 8) & 0xff) as u8;
            bin[i + 3] = ((out[j] >> 0) & 0xff) as u8;
            i += 4;
            j += 1;
        }
    }
    let mut leading_zeros: u8 = 0;
    let mut counting: bool = true;
    for j in 0..bin.len() {
        if counting & (bin[j] == 0) {
            leading_zeros += 1;
        } else {
            counting = false;
        }
    }

    let mut final_output: BoundedVec<u8, 90> = BoundedVec::new();
    let start_index = leading_zeros - zcount;

    let mut waiting = true;
    for i in 0..bin.len() {
        if waiting {
            if start_index == i as u8 {
                waiting = false;
                final_output.push(bin[i]);
            }
        } else {
            final_output.push(bin[i]);
        }
    }
    final_output
}
