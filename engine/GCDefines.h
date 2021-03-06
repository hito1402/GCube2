/*
 * The MIT License (MIT)
 * Copyright (c) 2013 GClue, inc.
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifndef GCube_GCDefines_h
#define GCube_GCDefines_h

#include <stddef.h>
#include <math.h>

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

// デバイスの向き
typedef enum GCDeviceOrientation
{
    GCDeviceOrientationUnknown,
    GCDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
    GCDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
    GCDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
    GCDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
    GCDeviceOrientationFaceUp,              // Device oriented flat, face up
    GCDeviceOrientationFaceDown             // Device oriented flat, face down
}
GCDeviceOrientation;

// タッチイベント
typedef enum GCTouchAction
{
    GCTouchActionDown,
    GCTouchActionUp,
    GCTouchActionMove,
    GCTouchActionCancel,
}
GCTouchAction;

namespace GCube {
	class Main;
	class ApplicationController;
}

#endif
