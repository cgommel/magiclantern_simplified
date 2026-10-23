/** \file
 * Entry points into the firmware image.
 *
 * These are the functions that we can call from our tasks
 * in the Canon 1.0.1 firmware for the EOS 760D.
 *
 */
/*
 * Copyright (C) 2021 Magic Lantern Team
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor,
 * Boston, MA  02110-1301, USA.
 */

#include <stub.h>

/* Warning: there are some ARM32 stubs, not only thumb! */

/** Startup **/
NSTUB(MAIN_FIRMWARE_ADDR,  firmware_entry)
THUMB_FN(0xfe0cd1d0,  pre_cstart_func) // needed to easily patch for compacting firmware_entry and cstart regions; 760D: bl from firmware_entry fe0a00a4
THUMB_FN(0xfe0cd1f0,  cstart)                               // calls bzero32 and create_init_task(..., init_task, ...); 760D: b.w from firmware_entry fe0a00fe
ARM32_FN(0x800072c0,  bzero32)                              // zeros out a data structure; 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(0x80000f78,  create_init_task)                     // low-level DryOS initialization; 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(0xfe0cd418,  init_task)                            // USER_MEM size checking, dmSetup, termDriverInit, stdlibSetup etc; 760D: passed to create_init_task in cstart (literal fe0cd288)

/** Tasks **/
//DATA_PTR(    0x44D0,  interrupt_level)
DATA_PTR(    0x44D4,  current_interrupt) // See fe0cd12c() which uses both current_interrupt and interrupt_level.; 760D: same as 750D, per qemu-eos cam_config/760D/debugmsg.gdb
                                         // It's read from d4011000, this was consistent on 3 Digic 6 cams I checked.
DATA_PTR(    0x44F4,  current_task)                         // from task_create; pointer to the current task structure; 760D: same as 750D, per qemu-eos cam_config/760D/debugmsg.gdb
THUMB_FN(    0x1a9c,  msleep)                               // argument is always multiple of 10; 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(    0x1e44,  task_create)                          // used to start TaskMain, GuiMainTask etc; 760D: same as 750D, prologue checked in RAM dump
DATA_PTR(    0x4678,  task_max) // 760D: same as 750D (DryOS kernel area, unverified)

/** File I/O **/
THUMB_FN(0xfe455606, _FIO_CreateFile) // 760D: FIO cluster +0x11968, 14/14 prologues (750D: 0xfe443c9e)
THUMB_FN(0xfe455590, _FIO_OpenFile) // 760D: FIO cluster +0x11968, 14/14 prologues (750D: 0xfe443c28)
THUMB_FN(0xfe45585c,  FIO_CloseFile) // 760D: FIO cluster +0x11968, 14/14 prologues (750D: 0xfe443ef4)
THUMB_FN(0xfe4556dc, _FIO_ReadFile) // 760D: FIO cluster +0x11968, 14/14 prologues (750D: 0xfe443d74)
THUMB_FN(0xfe4557ee, _FIO_WriteFile) // 760D: FIO cluster +0x11968, 14/14 prologues (750D: 0xfe443e86)
THUMB_FN(0xfe45574c,  FIO_SeekSkipFile) // 760D: FIO cluster +0x11968, 14/14 prologues (750D: 0xfe443de4)
THUMB_FN(0xfe455948, _FIO_GetFileSize) // 760D: FIO cluster +0x11968, 14/14 prologues (750D: 0xfe443fe0)
THUMB_FN(0xfe455670, _FIO_RemoveFile) // 760D: FIO cluster +0x11968, 14/14 prologues (750D: 0xfe443d08)
THUMB_FN(0xfe455ccc, _FIO_RenameFile)                       // FIO_RenameFile_Success; 760D: FIO cluster +0x11968, 14/14 prologues (750D: 0xfe444364)
THUMB_FN(0xfe455e4a, _FIO_CreateDirectory) // 760D: FIO cluster +0x11968, 14/14 prologues (750D: 0xfe4444e2)
THUMB_FN(0xfe456212, _FIO_FindFirstEx) // 760D: FIO cluster +0x11968, 14/14 prologues (750D: 0xfe4448aa)
THUMB_FN(0xfe4562a6,  FIO_FindNextEx) // 760D: FIO cluster +0x11968, 14/14 prologues (750D: 0xfe44493e)
THUMB_FN(0xfe456328,  FIO_FindClose) // 760D: FIO cluster +0x11968, 14/14 prologues (750D: 0xfe4449c0)
THUMB_FN(0xfe455f3a,  FIO_Flush) // 760D: FIO cluster +0x11968, 14/14 prologues (750D: 0xfe4445d2)

/** Debug messages **/
THUMB_FN(     0x268,  DryosDebugMsg)                        // lots of debug messages; format string is third argument; 760D: same as 750D, prologue checked in RAM dump

/** Eventprocs (call by name) **/
THUMB_FN(0xfe458dc6,  call)                                 // many functions called by name (lv_start, lv_stop etc); 760D: varargs: looks up name in func table (bl fe32e9b6), then blx found func (750D: 0xfe445e02)

/** GUI timers **/
THUMB_FN(0xfe48c4ea,  SetHPTimerNextTick)                   // same "worker" function as SetHPTimerAfterNow; 760D: HPTimer cluster +0x170d14, 3/3 (750D: 0xfe31b7d6)
THUMB_FN(0xfe48c49a,  SetHPTimerAfterNow)                   // from error message; 760D: bl before 'adapterDelayMicroSecond : SetHPTimerAfterNow' (fe61dee6) (750D: 0xfe31b786)
THUMB_FN(0xfe457e30,  SetTimerAfter)                        // from error message; 760D: bl before 'SetTimerAfter (%#x)' (fe262c86) (750D: 0xfe44a3bc)
THUMB_FN(0xfe457ea2,  CancelTimer)                          // CancelRefreshTimer, CancelTimer; 760D: +0x72 from SetTimerAfter as on 750D (750D: 0xfe44a42e)

/** Memory allocation **/
THUMB_FN(    0x10ea, _AllocateMemory)                       // via _alloc_dma_memory; 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(    0x1284, _FreeMemory)                           // via _free_dma_memory; 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(     0xf94,  GetMemoryInformation)                 // via _AllocateMemory; 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(     0xf68,  GetSizeOfMaxRegion)                   // via _AllocateMemory; 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(0x800056ec, _alloc_dma_memory) // 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(0x80005718, _free_dma_memory) // 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(0xfe538224, _malloc)                               // called before "can't malloc"; 760D: called before 'can't malloc' (fe20377e) (750D: 0xfe50b4c0)
THUMB_FN(0xfe53825a, _free)                                 // called later on the same buffer; 760D: +0x36 from _malloc as on 750D (750D: 0xfe50b4f6)

/** Memory info **/
THUMB_FN(0xfe22379c,  malloc_info)                          // Malloc Information; 760D: string 'Malloc Information', cluster +0x2d5a0 (750D: 0Xfe1f61fc)
// TODO 760D: THUMB_FN(0xfe1d7a54,  memmap_info)                          // Exception vector, DRYOS system memory etc
// TODO 760D: THUMB_FN(0xfe15c96a,  smemShowFix)                          // Common Lower, Common Upper etc
THUMB_FN(0xfe223834,  sysmem_info)                          // System Memory Information; 760D: string 'System Memory Information', cluster +0x2d5a0 (750D: 0xfe1f6294)

/** Misc **/
THUMB_FN(0xfe454c58,  uart_printf) // 760D: LIKELY: console printf(fmt,...) -> vfprintf to stdout stream 0x3b2c0 + flush; 1239 callers incl. malloc_info (750D: 0xfe465374)
THUMB_FN(0x8000469c,  vsnprintf)                            // from dryosdebugmsg, found via ""!!! ERROR !!!"'" print on uart; 760D: same as 750D, prologue checked in RAM dump

/** New stubs **/

/** Startup **/
DATA_PTR(   0x2bc34,  additional_version) // 760D: UNVERIFIED: 750D+0x38, holds a '1.0.0' version string, 2 ROM literals (750D: 0x2bbfc)
/* kitor: Please note that this points at '\n' char in char* with FW version */

/** Tasks **/
DATA_PTR(    0x46b4,  task_dispatch_hook) // 760D: same as 750D (DryOS kernel area, unverified)
THUMB_FN(0x80001722,  task_trampoline) // 760D: same as 750D, prologue checked in RAM dump
/*
 * kitor: task_create calls internal function (80000b88) which set up basic
 * task structure, and part of that is call to task_trampoline_caller (80001746)
 * (it is followed by check of caller return value).
 * task_trampoline_caller will pass task_trampoline+1 as parameter to another
 * function.
 */
THUMB_FN(0x80001358, _get_task_info_by_id) // 760D: same as 750D, prologue checked in RAM dump
/*
 * kitor: via extask (fe1d76d0). While on 5D3 it was called directly, now helper
 * is used. Find extask via string formats. Trace variables holding task id,
 * you will quickly find where it is verified (this is the mentioned helper).
 * In the helper code you will find call to our stub.
 */

/** Recursive locks **/
THUMB_FN(    0x3262,  CreateRecursiveLock)                  // "KernelDry/KerMisc.c"; 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(    0x3448,  AcquireRecursiveLock)                 // "KernelDry/KerRLock.c", used in WINSYS_CreateController(); 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(    0x3516,  ReleaseRecursiveLock)                 // "KernelDry/KerRLock.c"; 760D: same as 750D, prologue checked in RAM dump

/** Semaphores **/
THUMB_FN(    0x2fbc,  create_named_semaphore) // 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(    0x30b2,  take_semaphore)                       // GetEndGuiInitState Take/Give; 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(    0x3082,  take_semaphore_now) // 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(    0x312a,  give_semaphore) // 760D: same as 750D, prologue checked in RAM dump

/** GUI **/
DATA_PTR(   0x2d2dc,  gui_task_list)                        // via WINSYS_CreateController(); 760D: 750D+0x38 (app data block shift, cf. sd_device/LiveViewApp_dialog), 2 ROM literals (750D: 0x2d2a4)
DATA_PTR(    0x4b18,  gui_main_struct)                      // structure used by gui_main_task; 760D: same as 750D, literal fe1418bc in gui_main_task setup (750D: 0x4b18)
THUMB_FN(0xfe4523e4,  SetGUIRequestMode)                    // by debug message; 760D: DebugMsg 'SetGUIRequestMode' (750D: 0xfe4421ec)
THUMB_FN(0xfe141524,  gui_main_task)                        // task_create("GuiMainTask"...; 760D: task_create('GuiMainTask') arg, literal fe141940 (750D: 0xfe0f924c)
THUMB_FN(0xfe48c748,  gui_massive_event_loop)               // various "GUICMD_"* strings; 760D: HPTimer cluster +0x170d14, 3/3 (750D: 0xfe31ba34)
THUMB_FN(0xfe1414bc,  gui_enqueue_message)                  // via string "warning! QueueLength="; 760D: string 'warning! QueueLength=' (750D: 0xfe0f91e4)
THUMB_FN(0xfe4566d0,  gui_init_end)                         // EndGuiInit; 760D: strings 'ERR EndGuiInit: Not Init GuiLock' etc (750D: 0xfe173f10)
THUMB_FN(0xfe1416ca,  GUI_Control)                          // string GUI_Control; 760D: string 'GUI_Control', cluster +0x482d8 (750D: 0xfe0f93f2)

/** Dialog API **/
THUMB_FN(0xfe4675b8,  dialog_redraw)                        // DebugMsg "StartPlayErrorApp". Called just before assigning 0 to one of variables.; 760D: bl in StartPlayErrorApp (fe50fa66) right before str 0 (750D: 0xfe452136)
THUMB_FN(0xfe46194c,  dialog_set_property_str)              // DebugMsg "***** UpdateStroboZoomGuidance", called with char* buffer as 3rd param.; 760D: called with (dlg, 5, sp+4 buffer) after 'UpdateStroboZoomGuidance' (fe0c924a) (750D: 0xfe453a24)

/** GUI timers **/
THUMB_FN(0xfe675fc8,  CancelDateTimer)                      // by debug message; 760D: logs 'CancelDateTimer' as first action (750D: 0xfe654534)

/** Queue **/
THUMB_FN(    0x2ce8,  msg_queue_create)                     // easy to spot in create_gui_main_task aka GUI_initialize; 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(    0x2db0,  msg_queue_receive)                    // used on gui queue in gui_main_task; 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(    0x2f04,  msg_queue_post)                       // used in gui_enqueue_message; 760D: same as 750D, prologue checked in RAM dump
THUMB_FN(    0x2f3a,  msg_queue_count)                      // educated guess based on R/200D. Also xref from fn with "[TASK ERROR] GetNumOfEvent"; 760D: same as 750D, prologue checked in RAM dump

/** Memory **/
// SRM general
THUMB_FN(0xfe57571a,  AllocateMemoryResource)               // Assert m_pfAllocMemoryCBR; 760D: cluster +0x2d06c 3/3, anchored by asserts m_pf*MemoryCBR (750D: 0xfe5486ae)
THUMB_FN(0xfe575748,  AllocateContinuousMemoryResource)     // Assert m_pfContAllocMemoryCBR; 760D: cluster +0x2d06c 3/3, anchored by asserts m_pf*MemoryCBR (750D: 0xfe5486dc)
THUMB_FN(0xfe5757ee,  FreeMemoryResource)                   // Assert m_pfFreeMemoryCBR; 760D: cluster +0x2d06c 3/3, anchored by asserts m_pf*MemoryCBR (750D: 0xfe548782)
// SRM specific
THUMB_FN(0xfe4090f6,  SRM_AllocateMemoryResourceFor1stJob)  // via debug message with function name (after call). Function uses RscMgr strings; 760D: called before take_semaphore + msg 'SRM_AllocateMemoryResourceFor1stJob failed' (fe4122ca) (750D: 0xfe3f73ba)
THUMB_FN(0xfe40b446,  SRM_FreeMemoryResourceFor1stJob)      // used in functions related to deleting Skelton jobs; 760D: SRM cluster +0x11d3c, 2/2 (750D: 0xfe3f970a)
// MemorySuite, MemoryChunk
THUMB_FN(0xfe45442a,  ConcatMemorySuite)                    // Via debug msg with fn name (after call). Not used by ML, but utilizes functions below:; 760D: MemorySuite cluster +0x12dac, 8/8, anchored by DebugMsg 'DeleteMemorySuite 0x%x' (750D: 0xfe44167e)
THUMB_FN(0xfe453b68,  GetFirstChunkFromSuite)               // In ConcatMemorySuite(), First function called.; 760D: MemorySuite cluster +0x12dac, 8/8, anchored by DebugMsg 'DeleteMemorySuite 0x%x' (750D: 0xfe440dbc)
THUMB_FN(0xfe4543e4,  GetNextMemoryChunk)                   // In ConcatMemorySuite(), function called in first loop with param2 passed as 1st arg; 760D: MemorySuite cluster +0x12dac, 8/8, anchored by DebugMsg 'DeleteMemorySuite 0x%x' (750D: 0xfe441638)
THUMB_FN(0xfe453968,  GetMemoryAddressOfMemoryChunk)        // In ConcatMemorySuite(), uses param2 from GetNextMemoryChunk() as own param1; 760D: MemorySuite cluster +0x12dac, 8/8, anchored by DebugMsg 'DeleteMemorySuite 0x%x' (750D: 0xfe440bbc)
THUMB_FN(0xfe453516,  CreateMemoryChunk)                    // In ConcatMemorySuite(), just after calls to GetMemoryAddressOfMemoryChunk(); also called from CreateMemorySuite(); 760D: MemorySuite cluster +0x12dac, 8/8, anchored by DebugMsg 'DeleteMemorySuite 0x%x' (750D: 0xfe44076a)
THUMB_FN(0xfe453adc,  AddMemoryChunk)                       // In ConcatMemorySuite(), just after calls to CreateMemoryChunk(); 760D: MemorySuite cluster +0x12dac, 8/8, anchored by DebugMsg 'DeleteMemorySuite 0x%x' (750D: 0xfe440d30)
THUMB_FN(0xfe453fde,  CreateMemorySuite)                    // One of just a few xrefs of CreateMemoryChunk(); String "PackMem.c", calls malloc(0x18); 760D: MemorySuite cluster +0x12dac, 8/8, anchored by DebugMsg 'DeleteMemorySuite 0x%x' (750D: 0xfe441232)
THUMB_FN(0xfe453cf8,  DeleteMemorySuite)                    // DebugMsg "DeleteMemorySuite 0x%x"; 760D: MemorySuite cluster +0x12dac, 8/8, anchored by DebugMsg 'DeleteMemorySuite 0x%x' (750D: 0xfe440f4c)

/** Uncategorized **/
DATA_PTR(   0x2e0a4,  sd_device)                            // From function that references "SD_DeviceCreate:" TODO: check if stryct changed like in R; 760D: stored in SD_DeviceCreate fe280138 (literal fe280220) (750D: 0x2e06c)
THUMB_FN(0xfe6433d0,  _LoadCalendarFromRTC)                 // "Private" as it now has more arguments, needs a wrapper.; 760D: cluster with ErrForCamera_handler +0x2e444 (750D: 0xfe614f8c)
THUMB_FN(0xfe641caa,  ErrForCamera_handler)                 // ERR70, ERR80 etc (DlgErrForCamera.c); 760D: strings 'DlgErrForCamera.c TERMINATE_WINSYS' etc (750D: 0xfe613866)

/** Properties **/
THUMB_FN(0xfe4580ea,  prop_register_slave)                  // Assert "pRegisterSlave"; 760D: assert 'pRegisterSlave' (750D: 0xfe445136)
THUMB_FN(0xfe4581ba, _prop_request_change)                  // Assert "pRequestChange"; 2nd (almost identical) is at 0xfe44574a but uses different struct address - matched to struct from prop_register_slave(); 760D: assert 'pRequestChange', +0xd0 from prop_register_slave as on 750D (750D: 0xfe445206)
THUMB_FN(0xfe4586cc, _prop_cleanup)                         // DebugMsg "ChangeCBR(...". Last call in those functions.; 760D: prop cluster +0x12fb4 (3/4, call differs) (750D: 0xfe445718)

/** PTP **/
// TODO 760D: THUMB_FN(0xfe4196f2,  ptp_register_handler)                 // AddListOperationFunction wrapper; candidate for CONFIG_PTP

/** CFn **/
THUMB_FN(0xfe370e20, GetCFnData)                            // "GetCFnData"; 760D: strings '***** GetCFnData CFN_* unknown CfnNo' (750D: 0xFE3600D0)
THUMB_FN(0xfe370ebe, SetCFnData)                            // "SetCFnData"; 760D: strings '***** SetCFnData CFN_* unknown CfnNo', directly after GetCFnData (750D: 0xFE36016E)
/**
 * RGBA / Compositor functions and structures
 */

/** General FEATURE_VRAM_RGBA stubs **/
THUMB_FN(0xfe245594, XimrExe);                              //In RefreshVrmsSurface, just before "XimrExe" debug message; 760D: in RefreshVrmsSurface fe447994, called right before 'XimrExe' msg (750D: 0xfe2181d4)

/*
 * Pointer to first Canon RGBA buffer (GUI).
 * structure starts at 2d38c (750D) / 2d3c4 (760D) - easy to find from InitializeScreen
 *
 * 0x0  unknown
 * 0x4  is_initialized
 * 0x8  _rgb_vram_info (rgb buffer)
 * 0xc   bmp_vram_info.yuv1
 * 0x10  bmp_vram_info.yuv2
 * 0x14  bmp_vram_info.back_vram
 *
 * Structure is missing WinsysWait_v (vsync) semaphore as compared to D7+
 */
DATA_PTR(   0x2d3cc, _rgb_vram_info); // 760D: struct base 0x2d3c4 in RefreshVrmsSurface = 750D 0x2d38c + 0x38, same layout (750D: 0x2D394)
DATA_PTR(   0x2d3d0,  bmp_vram_info) // 760D: struct base 0x2d3c4 in RefreshVrmsSurface = 750D 0x2d38c + 0x38, same layout (750D: 0x2D398)

/** Wrong on purpose **/
DATA_PTR(       0x0,  LCD_Palette)                          // D6 has no indexed RGB buffers.; 760D: same as 750D (750D: 0x0)

/** App handlers **/
/**
 * Those can usually be found by looking at function address passed to
 * WINSYS_CreateDialogBox_wrapper / WINSYS_CreateDialogBox, just after some
 * debug message */
THUMB_FN(0xfe42286a,  PlayMain_handler)                     // msg: "StartPlayMain"; 760D: handler passed to CreateDialogBox (fe468012) in StartPlayMain fe423b20 (750D: 0xfe410e0a)
THUMB_FN(0xfe5baee4,  ShootOlcApp_handler)                  // msg: "StartShootOlcApp PushPalette(%d)"; 760D: handler passed to CreateDialogBox in StartShootOlcApp fe5bb788 (750D: 0xfe575c58)
THUMB_FN(0xfe3cbb20,  LiveViewApp_handler)                  // msg: "StartLiveViewApp(%#x)"; 760D: handler passed to CreateDialogBox in StartLiveViewApp fe3cd21a (750D: 0xfe3d5ecc)
//THUMB_FN(0xfe69c5d0,  LiveViewShutterApp_handler)         // msg: "LiveViewShutterApp"
THUMB_FN(0xfe48133e,  PlayMovieGuideApp_handler)            // msg: "StartPlayMovieGuideApp"; 760D: handler passed to CreateDialogBox in StartPlayMovieGuideApp fe481614 (750D: 0xfe31022e)

// See R180 stubs.s for details.
//DATA_PTR( 0x2BD60,  PlayMain_dialog)                      // in StartPlayMain(), 0x2bd54 + 0xc
//DATA_PTR( 0x35298,  ShootOlcApp_dialog)                   // in StartShootOlcApp()
DATA_PTR(   0x2fed0,  LiveViewApp_dialog)                   // in StartLiveViewApp(); 760D: CreateDialogBox result stored in StartLiveViewApp (literal fe3cd4d8) (750D: 0x2fe98)
//DATA_PTR( 0x35a58,  LiveViewShutterApp_dialog)            // in StartLiveViewShutterApp(), not sure if needed
//DATA_PTR( 0x3042c,  PlayMovieGuideApp_dialog)             // in StartPlayMovieGuideApp()
