
const { toHex } = web3.utils;
const Remittance = artifacts.require('./Remittance.sol');

contract('Remittance', accounts => {
    const [alice, carol, randomAddress] = accounts;
    let remittanceInstance, hashedCombo;

    beforeEach(async () => {
        remittanceInstance = await Remittance.new({ from: alice });
        hashedCombo = await remittance.generateHashedCombo(toHex("password"), carol);
    });

    it('depositFunds', async () => {
        await remittanceInstance.deposit(hashedCombo, 172800, { from: alice, value: 10 });

        const remittance = await remittanceInstance.remittances.call(hashedCombo);

        assert.strictEqual(remittance.amount.toString(10), "10");
        assert.strictEqual(remittance.originalSender, alice);
    });

    it('withdrawFunds', async () => {
        await remittanceInstance.deposit(hashedCombo, 172800, { from: alice, value: 10 });

        try {
            const balanceBefore = await web3.eth.getBalance(carol);
            const txObj = await remittance.withdrawFunds(toHex("password"), { from: carol });
            const hash = txObj.receipt.transactionHash;
            const tx = await web3.eth.getTransactionPromise(hash);
            const gasPrice = tx.gasPrice;
            const txFee = gasUsed * gasPrice;
            const balanceNow = await web3.eth.getBalancePromise(carol);

            const remittance = await remittanceInstance.remittances.call(hashedCombo);
            assert.strictEqual(remittance.amount.toString(10), "0");
            assert.strictEqual(balanceNow.toString(10), balanceBefore.plus(10).minus(txFee).toString(10), "wrong balance");


        } catch (e) {
            assert.strictEqual(err.reason, 'withdrawal failed');
        }
    });

    it('refundFunds', async () => {
        await remittanceInstance.deposit(hashedCombo, 172800, { from: alice, value: 10 });

        try {
            await remittance.refund(hashedCombo, { from: randomAddress });
        } catch (err) {
            assert.strictEqual(err.reason, 'refund failed');
        }

        // figure out how to send date to make this fail
    });
});