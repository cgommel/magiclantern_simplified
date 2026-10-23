#ifndef __platform_state_object_h
#define __platform_state_object_h

// EvfState. Found by comparing against 5D3
// 760D: found at runtime on the real cam - global at 0x26bbc points to the
// state object named "EvfState" (750D 0x26b94 + 0x28, struct filled in fe2e6c10)
#define EVF_STATE (*(struct state_object **)0x26bbc)

#endif // __platform_state_object_h
