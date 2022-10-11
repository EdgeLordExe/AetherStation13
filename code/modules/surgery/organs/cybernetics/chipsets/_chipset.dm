/obj/item/chipset
	name = "Generic chipset"
	desc = "You should NEVER see this!"
	icon = 'icons/obj/chipset.dmi'
	var/base_state
	var/top_state

/obj/item/chipset/Initialize()
	. = ..()
	if(!base_state)
		base_state = "base-[rand(0,4)]"
	if(!top_state)
		top_state = "top-[pick("nt","nt2","syndie","tg","makeshift")]"
	icon_state = base_state
	add_overlay(image(icon=src.icon,icon_state=top_state))

/obj/item/chipset/proc/can_insert(obj/item/organ/cyberimp/cyberlink/link,mob/living/carbon/human/owner)
	return TRUE

/obj/item/chipset/proc/on_insert(obj/item/organ/cyberimp/cyberlink/link,mob/living/carbon/human/owner)
	return

/obj/item/chipset/proc/on_eject(obj/item/organ/cyberimp/cyberlink/link,mob/living/carbon/human/owner)
	return

/obj/item/chipset/protocol
	desc = "This chipset contains protocols necessary to increase your cyberlink capabilities."
	var/protocol_type
	var/protocol

/obj/item/chipset/protocol/Initialize()
	. = ..()
	name = "Protcol ([protocol_type]) chipset ([protocol])"

/obj/item/chipset/protocol/can_insert(obj/item/organ/cyberimp/cyberlink/link, mob/living/carbon/human/owner)
	. = ..()
	if(protocol in link.encode_info[protocol_type])
		to_chat(owner,span_warning("This cyberlink already contains the protocols in the chipset!"))
		return FALSE

/obj/item/chipset/protocol/on_insert(obj/item/organ/cyberimp/cyberlink/link, mob/living/carbon/human/owner)
	link.encode_info[protocol_type] += protocol

/obj/item/chipset/protocol/on_eject(obj/item/organ/cyberimp/cyberlink/link, mob/living/carbon/human/owner)
	link.encode_info[protocol_type] -= protocol

/obj/item/chipset/protocol/security
	protocol_type = SECURITY_PROTOCOL

/obj/item/chipset/protocol/encode
	protocol_type = ENCODE_PROTOCOL

/obj/item/chipset/protocol/operating
	protocol_type = OPERATING_PROTOCOL
