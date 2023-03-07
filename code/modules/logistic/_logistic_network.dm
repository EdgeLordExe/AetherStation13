#define LOGISTIC_PULL "pull"
#define LOGISTIC_PUSH "push"



/datum/logistic_interface
	var/list/addresses
	var/list/storage = list()

/datum/logistic_interface/proc/get_partial_address()
	return "LI"

/datum/logistic_interface/proc/poll()
	. = list()
	.[LOGISTIC_PULL] = list()
	.[LOGISTIC_PUSH] = list()
	return

/datum/logistic_interface/proc/get(item_type)
	var/item = storage[item_type][1]
	storage[item_type][1].Cut(1,2)
	return item

/datum/logistic_interface/proc/insert(obj/item/I)
	LAZYADD(storage[I.type],I)
	I.moveToNullspace()

/datum/logistic_interface/provider
	var/list/export = list()

/datum/logistic_interface/provider/get_partial_address()
	. = ..()
	. += "-P::"

/datum/logistic_interface/provider/poll()
	. = ..()
	.[LOGISTIC_PULL] += export
	export.Cut()

/datum/logistic_interface/insert(obj/item/I)
	. = ..()
	export += I.type

/datum/logistic_network
	var/list/pipes = list()
	var/list/interfaces = list()

	var/list/requests = list()
	var/list/exports = list()

/datum/logistic_network/proc/register_interface(datum/logistic_interface/interface)
	if(isnull(interface))
		stack_trace("Interface cannot be null!")
	if(interface in interfaces)
		return
	var/len = interfaces.len
	var/address = interface.get_partial_address() + (len > 99 ? "[len]" : ( len > 9 ? "0[len]" : "00[len]"))
	interfaces[address] = interface
	LAZYADDASSOC(interfaces.addresses,src,address)

/datum/logistic_network/proc/process(delta_time)
	var/list/data = poll_interfaces()

	for(var/address in data[INTERFACE_PULL])
		for(var/request in data[INTERFACE_PULL][address])
			LAZYADD(requests[request],address)

	for(var/address in data[INTERFACE_PUSH])
		for(var/provide in data[INTERFACE_PUSH][address])
			LAZYADD(exports[provide],address)

	for(var/request in requests)
		if(!isnull(exports[request]))
			var/datum/logistic_interface/provider = interfaces[exports[request][1]]
			var/datum/logistic_interface/reciever = interfaces[requests[request][1]]
			exports[request].Cut(1,2)
			requests[request].Cut(1,2)
			reciever.insert(provider.get(request))

/datum/logistic_network/proc/poll_interfaces()
	. = list()
	.[INTERFACE_PUSH] = list()
	.[INTERFACE_PULL] = list()
	for(var/address in interfaces)
		var/datum/logistic_interface/interface = interfaces[address]
		var/list/polled = interface.poll()
		.[INTERFACE_PUSH][address] = polled[INTERFACE_PUSH]
		.[INTERFACE_PULL][address] = polled[INTERFACE_PULL]

/datum/logistic_network/proc/merge(datum/logistic_network/other)
	var/list/other_interfaces = list()
	for(var/address in other.interfaces)
		other_interfaces += other.interfaces[address]

	var/list/our_interfaces = list()
	for(var/address in interfaces)
		our_interfaces += interfaces[address]

	var/list/mapping = list()
	var/list/common_interfaces = our_interfaces & other_interfaces
	for(var/common_address in common_interfaces)
		var/datum/logistic_interface/interface = common_interfaces[common_address]
		mapping[interface.addresses[other]] = interface.addresses[src]

	for(var/other_address in (other_interfaces - common_interfaces))
		var/len = interfaces.len
		var/new_address = other_interfaces[other_address].get_partial_address() + (len > 99 ? "[len]" : ( len > 9 ? "0[len]" : "00[len]"))
