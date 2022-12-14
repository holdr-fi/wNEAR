import { expect } from 'chai';
import { ethers } from 'hardhat';
import { WNEAR } from '../typechain-types';
import { BigNumber as BN, Contract, constants } from 'ethers';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import ERC20ABI from '../abis/ERC20.json';
const { MaxUint256, AddressZero } = constants;

describe('wNEAR', function () {
  let wNEAR: WNEAR;
  let poorGuy: SignerWithAddress;
  let richGuy: SignerWithAddress;
  let NEAR: Contract;

  const NEAR_ADDRESS = '0xC42C30aC6Cc15faC9bD938618BcaA1a1FaE8501d';
  const RICH_NEAR_WALLET = '0xC84E29955D4Fc6e71189558529E3d66fDC2402F6';
  const SCALE_FACTOR = BN.from(10).pow(6);

  before(async () => {
    [poorGuy] = await ethers.getSigners();
    richGuy = await ethers.getImpersonatedSigner(RICH_NEAR_WALLET);
    NEAR = new ethers.Contract(NEAR_ADDRESS, ERC20ABI, poorGuy.provider);
    const WNEAR = await ethers.getContractFactory('WNEAR');
    wNEAR = await WNEAR.deploy();
  });

  describe('Initialization', function () {
    it('decimals', async function () {
      expect(await wNEAR.decimals()).eq(18);
    });
    it('name', async function () {
      expect(await wNEAR.name()).eq('Wrapped NEAR');
    });
    it('symbol', async function () {
      expect(await wNEAR.symbol()).eq('wNEAR');
    });
    it('totalSupply', async function () {
      expect(await wNEAR.totalSupply()).eq(0);
    });
    it('balanceOf', async function () {
      expect(await wNEAR.balanceOf(poorGuy.address)).eq(0);
    });
  });

  describe('Wrapping function', function () {
    it('richGuy wrap and unwrap 1818181818181818181818181 wNEAR', async function () {
      const amount = BN.from('1818181818181818181818181');
      const [beforeNEARBalance, beforeWNEARbalance] = await Promise.all([
        NEAR.balanceOf(RICH_NEAR_WALLET),
        wNEAR.balanceOf(RICH_NEAR_WALLET),
      ]);

      await NEAR.connect(richGuy).approve(wNEAR.address, MaxUint256);

      {
        const tx = await wNEAR.connect(richGuy).deposit(amount);
        await expect(tx)
          .to.emit(NEAR, 'Transfer')
          .withArgs(richGuy.address, wNEAR.address, amount.div(SCALE_FACTOR).mul(SCALE_FACTOR));
        await expect(tx).to.emit(wNEAR, 'Transfer').withArgs(AddressZero, richGuy.address, amount.div(SCALE_FACTOR));
      }

      const [afterDepositNEARBalance, afterDepositWNEARbalance] = await Promise.all([
        NEAR.balanceOf(RICH_NEAR_WALLET),
        wNEAR.balanceOf(RICH_NEAR_WALLET),
      ]);

      expect(afterDepositNEARBalance.sub(beforeNEARBalance)).eq(amount.div(SCALE_FACTOR).mul(SCALE_FACTOR).mul(-1));
      expect(afterDepositWNEARbalance.sub(beforeWNEARbalance)).eq(amount.div(SCALE_FACTOR));

      {
        const tx = await wNEAR.connect(richGuy).withdraw(amount.div(SCALE_FACTOR));
        await expect(tx)
          .to.emit(NEAR, 'Transfer')
          .withArgs(wNEAR.address, richGuy.address, amount.div(SCALE_FACTOR).mul(SCALE_FACTOR));
        await expect(tx).to.emit(wNEAR, 'Transfer').withArgs(richGuy.address, AddressZero, amount.div(SCALE_FACTOR));
      }

      const [afterWithdrawNEARBalance, afterWithdrawWNEARbalance] = await Promise.all([
        NEAR.balanceOf(RICH_NEAR_WALLET),
        wNEAR.balanceOf(RICH_NEAR_WALLET),
      ]);

      expect(afterWithdrawNEARBalance).eq(beforeNEARBalance);
      expect(afterWithdrawWNEARbalance).eq(beforeWNEARbalance);
      expect(await wNEAR.totalSupply()).eq(0);
      expect(await NEAR.balanceOf(wNEAR.address)).eq(0);
    });
    it('poorGuy with no NEAR cannot mint wNEAR', async function () {
      expect(await NEAR.balanceOf(poorGuy.address)).eq(0);
      await NEAR.connect(poorGuy).approve(wNEAR.address, MaxUint256);
      await expect(wNEAR.connect(poorGuy).deposit(1)).to.be.revertedWith('insufficient NEAR balance');
    });
    it('poorGuy with no wNEAR cannot take out NEAR', async function () {
      expect(await wNEAR.balanceOf(poorGuy.address)).eq(0);
      await wNEAR.connect(richGuy).deposit(SCALE_FACTOR.mul(1000));
      await expect(wNEAR.connect(poorGuy).withdraw(1)).to.be.revertedWith('ERC20: burn amount exceeds balance');
    });
    it('poorGuy can take out NEAR if they are given wNEAR', async function () {
      await wNEAR.connect(richGuy).transfer(poorGuy.address, 1000);
      expect(await wNEAR.balanceOf(richGuy.address)).eq(0);
      const tx = await wNEAR.connect(poorGuy).withdraw(1000);
      expect(await wNEAR.balanceOf(poorGuy.address)).eq(0);
      expect(await NEAR.balanceOf(poorGuy.address)).eq(SCALE_FACTOR.mul(1000));
      expect(await wNEAR.totalSupply()).eq(0);
    });
  });
});
