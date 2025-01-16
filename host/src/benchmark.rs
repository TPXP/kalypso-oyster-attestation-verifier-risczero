use clap::Parser;
use methods::{GUEST_ELF, GUEST_ID};
use risc0_zkvm::{default_prover, ExecutorEnv, ProverOpts};

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    #[arg(short, long)]
    url: String,
}

fn main() {
    log::info!("Request received by the risc0 prover");

    let attestation = hex::decode("8444a1013822a059114ca9696d6f64756c655f69647827692d30333761643062666262303136366362322d656e633031393330646662393665666331366266646967657374665348413338346974696d657374616d701b000001931ff245bf6470637273b00058308e37a5f8d21be3ff0fed8f1d6cdf603231f2da2f7728ba7f3615350403c2f15782cad045acbb088fa0ef7692bff4ac7b0158300343b056cd8485ca7890ddd833476d78460aed2aa161548e4e26bedf321726696257d623e8805f3f605946b3d8b0c6aa025830012b06aca4517141ac11b32ae10b51003882f251a162b776a1ebfd77afd5730b7b099bbc4baef259a30a7c4aad2612fa035830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045830519bc97304b6482652b1271a952851329f880ba65bca61026f99981125219ee6576be9fdddfa3b14d7936f6b48eb6a8d0558300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000658300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000758300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000858300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000958300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a58300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b58300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c58300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d58300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e58300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f58300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006b63657274696669636174655902813082027d30820203a003020102021001930dfb96efc16b0000000067332faf300a06082a8648ce3d04030330818f310b30090603550406130255533113301106035504080c0a57617368696e67746f6e3110300e06035504070c0753656174746c65310f300d060355040a0c06416d617a6f6e310c300a060355040b0c03415753313a303806035504030c31692d30333761643062666262303136366362322e61702d736f7574682d312e6177732e6e6974726f2d656e636c61766573301e170d3234313131323130333632385a170d3234313131323133333633315a308194310b30090603550406130255533113301106035504080c0a57617368696e67746f6e3110300e06035504070c0753656174746c65310f300d060355040a0c06416d617a6f6e310c300a060355040b0c03415753313f303d06035504030c36692d30333761643062666262303136366362322d656e63303139333064666239366566633136622e61702d736f7574682d312e6177733076301006072a8648ce3d020106052b8104002203620004d08745e83f8d90083de9fce2524e106c948907063ea845db77e6c51051bd0e101093de60f38172139a186454c1ff324a3e7903c832ee9d9f186083e9c4cf76ac492e92d5c690e8e9f52d79593434ae550eaf08225988c0c1bcc627377c8373c9a31d301b300c0603551d130101ff04023000300b0603551d0f0404030206c0300a06082a8648ce3d040303036800306502302bfe70aed4d2e1a4bc480ad3dfeb299edf858c38f99a404b69fec4d289ade00120fc4af1ed243b1c06df810d047e61bc023100f376cf3ca3202045c9cbd951821d8f0f9c72cc1a2d8fc1846ba88cdcb2bad65b6c06658daf2e29d68f9850fd030bc45568636162756e646c65845902153082021130820196a003020102021100f93175681b90afe11d46ccb4e4e7f856300a06082a8648ce3d0403033049310b3009060355040613025553310f300d060355040a0c06416d617a6f6e310c300a060355040b0c03415753311b301906035504030c126177732e6e6974726f2d656e636c61766573301e170d3139313032383133323830355a170d3439313032383134323830355a3049310b3009060355040613025553310f300d060355040a0c06416d617a6f6e310c300a060355040b0c03415753311b301906035504030c126177732e6e6974726f2d656e636c617665733076301006072a8648ce3d020106052b8104002203620004fc0254eba608c1f36870e29ada90be46383292736e894bfff672d989444b5051e534a4b1f6dbe3c0bc581a32b7b176070ede12d69a3fea211b66e752cf7dd1dd095f6f1370f4170843d9dc100121e4cf63012809664487c9796284304dc53ff4a3423040300f0603551d130101ff040530030101ff301d0603551d0e041604149025b50dd90547e796c396fa729dcf99a9df4b96300e0603551d0f0101ff040403020186300a06082a8648ce3d0403030369003066023100a37f2f91a1c9bd5ee7b8627c1698d255038e1f0343f95b63a9628c3d39809545a11ebcbf2e3b55d8aeee71b4c3d6adf3023100a2f39b1605b27028a5dd4ba069b5016e65b4fbde8fe0061d6a53197f9cdaf5d943bc61fc2beb03cb6fee8d2302f3dff65902c5308202c130820246a00302010202110093614ec7a819783167a99b7080142297300a06082a8648ce3d0403033049310b3009060355040613025553310f300d060355040a0c06416d617a6f6e310c300a060355040b0c03415753311b301906035504030c126177732e6e6974726f2d656e636c61766573301e170d3234313130373037333631345a170d3234313132373038333631345a3065310b3009060355040613025553310f300d060355040a0c06416d617a6f6e310c300a060355040b0c034157533137303506035504030c2e373764363832633332356134373461342e61702d736f7574682d312e6177732e6e6974726f2d656e636c617665733076301006072a8648ce3d020106052b810400220362000486b7b332f05f7eb6b907324d90777f219feb3cf52df72e417425a585126f9be5f189eb455aa48d3b81309c5b3194637c8734c9f0ed3d83028b773b38c04cc0b1081975eb2ba4e4405d8847c4465cb8d5cdf8b3a0db395d5ad63ad658aa43cff5a381d53081d230120603551d130101ff040830060101ff020102301f0603551d230418301680149025b50dd90547e796c396fa729dcf99a9df4b96301d0603551d0e04160414f699e6455d27085684c7c77905a165a1dd8f8374300e0603551d0f0101ff040403020186306c0603551d1f046530633061a05fa05d865b687474703a2f2f6177732d6e6974726f2d656e636c617665732d63726c2e73332e616d617a6f6e6177732e636f6d2f63726c2f61623439363063632d376436332d343262642d396539662d3539333338636236376638342e63726c300a06082a8648ce3d0403030369003066023100ec154bf1800ae20e5a755b0af9303c7130d15473cb6e302e1b2e55ba013eaedf517b34f1574410e4cb9e898d54807061023100e64daf48d39c114e4d5b52852c4647e9eafb7b342969661d682450cca83cc02aa1847edeaf533ddc3a2f936df8d4082159031d308203193082029fa00302010202110092542f12907fe8f7d21477be060e4861300a06082a8648ce3d0403033065310b3009060355040613025553310f300d060355040a0c06416d617a6f6e310c300a060355040b0c034157533137303506035504030c2e373764363832633332356134373461342e61702d736f7574682d312e6177732e6e6974726f2d656e636c61766573301e170d3234313131313138353935305a170d3234313131373132353935305a30818a313d303b06035504030c34366261626239613731383362353338302e7a6f6e616c2e61702d736f7574682d312e6177732e6e6974726f2d656e636c61766573310c300a060355040b0c03415753310f300d060355040a0c06416d617a6f6e310b3009060355040613025553310b300906035504080c0257413110300e06035504070c0753656174746c653076301006072a8648ce3d020106052b81040022036200040a56ab69d8a593e72fef7e5f9e3eca22c8cd09e107dea3b71d9f705c0e860a28949341d98ad2f9539082d34b9d128060d8fd68665583b806db22bb574e22eb940d6e540435d7d01ea78b65c8ee7a8d19a285e10a0be9a1256e92d5b1ac959ec8a381ec3081e930120603551d130101ff040830060101ff020101301f0603551d23041830168014f699e6455d27085684c7c77905a165a1dd8f8374301d0603551d0e04160414ac89d87fd0dc754a85c706b4bc8003703e3f49dc300e0603551d0f0101ff0404030201863081820603551d1f047b30793077a075a0738671687474703a2f2f63726c2d61702d736f7574682d312d6177732d6e6974726f2d656e636c617665732e73332e61702d736f7574682d312e616d617a6f6e6177732e636f6d2f63726c2f62666365623636332d306438302d346438662d393631322d3630666665663838646135352e63726c300a06082a8648ce3d0403030368003065023062786f665d22b068f8448defb7087c83732d9f58a23a4e49ddf48581c5339000e500035e7edb40804c4741b2e30f467e02310097ecc3f3a9ebca885da0973bdbff12b23b866327ccd5a3fb192d7f787b843db474f97e82faa18a1d4626a80bdce64d6c5902c5308202c130820247a003020102021500b076cfdbedc7d46d949daa1da0a872cd96ca755c300a06082a8648ce3d04030330818a313d303b06035504030c34366261626239613731383362353338302e7a6f6e616c2e61702d736f7574682d312e6177732e6e6974726f2d656e636c61766573310c300a060355040b0c03415753310f300d060355040a0c06416d617a6f6e310b3009060355040613025553310b300906035504080c0257413110300e06035504070c0753656174746c65301e170d3234313131313233303234335a170d3234313131323233303234335a30818f310b30090603550406130255533113301106035504080c0a57617368696e67746f6e3110300e06035504070c0753656174746c65310f300d060355040a0c06416d617a6f6e310c300a060355040b0c03415753313a303806035504030c31692d30333761643062666262303136366362322e61702d736f7574682d312e6177732e6e6974726f2d656e636c617665733076301006072a8648ce3d020106052b81040022036200047ece18b9de4126edc6844a28025cd45522b675743fca239fed160c557754e9818e396a172ed341ba9a359df90d0a2f9abf777a987c8c9c3e337d996232082bac608359727ed4c7d9e75d1fe01066a99dfd94a0629d9888b56a49d57b2f2024c3a366306430120603551d130101ff040830060101ff020100300e0603551d0f0101ff040403020204301d0603551d0e041604145fa4dd2d72c18ae20811bc06a795bd9e1be86614301f0603551d23041830168014ac89d87fd0dc754a85c706b4bc8003703e3f49dc300a06082a8648ce3d0403030368003065023100ef964c232ed5cc1802dfc888aa264669cd8f9454bba78fa187dc878b003c4b26765df23065f5928aedb71081ca7db21f02302f00aa82bc79c2c5d5fa30879cfb9ac4fb8fb45b02115df5a3bf349315d0400d88a6057cc56af54e2e38684921328d4f6a7075626c69635f6b657958409e84d3ce690f1c8bcddb21087b8d8a314ec64579607e233b303c09f288a5732ada2db25bdbf1d5b4811fb2838a16f6e59424ec99de79fc387d53818bff9d859369757365725f64617461f6656e6f6e6365f658607c6d44dd0bca2436cda1c8db29e82a7b881290040b0df70666dc560d8881756df30370c38f014d64b6b0d0b3fdc287cdde69978e7192dbfe3c1b169910e1b6bb27b771742b46ee19fa0ff7c7b38b642a858a27b05e351f6800929de506e5eac2").unwrap();

    println!("Attestation size: {}", attestation.len());

    let env = ExecutorEnv::builder()
        .write_slice(&attestation)
        .build()
        .unwrap();

    let prover = default_prover();

    // Enable groth16
    let prove_info = prover
        .prove_with_opts(env, GUEST_ELF, &ProverOpts::groth16())
        .unwrap();

    let receipt = prove_info.receipt;

    println!("{:?}", receipt);

    // let seal = receipt.inner.groth16().unwrap().seal.clone();

    // prefix 50bd1769 bytes to seal, og seal wont work on contracts

    println!(
        "Seal without prefix: {}",
        hex::encode(receipt.inner.groth16().unwrap().seal.clone())
    );

    // possible seals
    // 0x310fe598
    // 0x50bd1769
    // 0xc101b42b

    let seal_with_prefix: Vec<u8> = vec![0xc1, 0x01, 0xb4, 0x2b]
        .into_iter()
        .chain(receipt.inner.groth16().unwrap().seal.clone())
        .collect();
    let guest = GUEST_ID.map(u32::to_le_bytes);
    let image_id = guest.as_flattened();
    let journal = receipt.journal.bytes;

    println!("Seal with prefix: {}", hex::encode(&seal_with_prefix));

    let value = vec![
        ethers::abi::Token::Bytes(seal_with_prefix),
        ethers::abi::Token::FixedBytes(image_id.to_vec()),
        ethers::abi::Token::Bytes(journal),
    ];
    let encoded = ethers::abi::encode(&value);

    println!("Proof: {}", hex::encode(&encoded));
    println!("Inputs: {}", hex::encode(&attestation));

    let value = vec![
        ethers::abi::Token::Bytes(attestation.into()),
        ethers::abi::Token::Bytes(encoded.into()),
    ];

    let inputs_and_proof = ethers::abi::encode(&value);

    println!(
        "InputsAndProofEncoded: 0x{}",
        hex::encode(&inputs_and_proof)
    );
}
