import { newMockEvent } from "matchstick-as"
import { ethereum, BigInt, Address } from "@graphprotocol/graph-ts"
import {
  EIP712DomainChanged,
  Listed,
  Purchased
} from "../generated/NFTMarket/NFTMarket"

export function createEIP712DomainChangedEvent(): EIP712DomainChanged {
  let eip712DomainChangedEvent = changetype<EIP712DomainChanged>(newMockEvent())

  eip712DomainChangedEvent.parameters = new Array()

  return eip712DomainChangedEvent
}

export function createListedEvent(
  tokenId: BigInt,
  seller: Address,
  price: BigInt
): Listed {
  let listedEvent = changetype<Listed>(newMockEvent())

  listedEvent.parameters = new Array()

  listedEvent.parameters.push(
    new ethereum.EventParam(
      "tokenId",
      ethereum.Value.fromUnsignedBigInt(tokenId)
    )
  )
  listedEvent.parameters.push(
    new ethereum.EventParam("seller", ethereum.Value.fromAddress(seller))
  )
  listedEvent.parameters.push(
    new ethereum.EventParam("price", ethereum.Value.fromUnsignedBigInt(price))
  )

  return listedEvent
}

export function createPurchasedEvent(
  tokenId: BigInt,
  buyer: Address,
  seller: Address,
  price: BigInt
): Purchased {
  let purchasedEvent = changetype<Purchased>(newMockEvent())

  purchasedEvent.parameters = new Array()

  purchasedEvent.parameters.push(
    new ethereum.EventParam(
      "tokenId",
      ethereum.Value.fromUnsignedBigInt(tokenId)
    )
  )
  purchasedEvent.parameters.push(
    new ethereum.EventParam("buyer", ethereum.Value.fromAddress(buyer))
  )
  purchasedEvent.parameters.push(
    new ethereum.EventParam("seller", ethereum.Value.fromAddress(seller))
  )
  purchasedEvent.parameters.push(
    new ethereum.EventParam("price", ethereum.Value.fromUnsignedBigInt(price))
  )

  return purchasedEvent
}
