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

#import "GCViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <GCube.h>
#import <GCubeConfig.h>

using namespace GCube;

@interface GCViewController () {
	ApplicationController *gcube;
	CMMotionManager *motionMgr;
}
@property (strong, nonatomic) EAGLContext *context;
@end

@implementation GCViewController

// view読み込み
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	gcube = ApplicationController::SharedInstance();
	
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	self.preferredFramesPerSecond = __GCube_FrameRate__;

	NSAssert(self.context, @"Failed to create ES context");
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.context];
	
	float scale = [UIScreen mainScreen].scale;
	gcube->onSizeChanged(view.bounds.size.width*scale, view.bounds.size.height*scale, (GCDeviceOrientation)self.interfaceOrientation);
	
#ifdef __GCube_OrientationSensor__
	// 傾きセンサー開始
	[self startMotionSensor];
#endif
}

// 後処理
- (void)dealloc
{

#ifdef __GCube_OrientationSensor__
	[self stopMotionSensor];
#endif
	
    [EAGLContext setCurrentContext:self.context];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

// メモリ不足
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	gcube->onLowMemory();
}


#pragma mark - GLKView and GLKViewController delegate methods

// 処理
- (void)update
{
	
#ifdef __GCube_OrientationSensor__
	// 傾き取得（Androidを基準に値を変換）
	CMAttitude *currentAttitude = motionMgr.deviceMotion.attitude;
	double roll = currentAttitude.roll;  // Y軸中心のラジアン角: -π〜π(-180度〜180度)
	double pitch = -currentAttitude.pitch; // X軸中心のラジアン角: -π/2〜π/2(-90度〜90度)
	double yaw = -M_PI_2-currentAttitude.yaw;  // Z軸中心のラジアン角: -π〜π(-180度〜180度)
	if (yaw < -M_PI) yaw += (2.0*M_PI);
	if (!(pitch==0 && roll==0)) {
		gcube->onOrientationChanged(yaw, pitch, roll);
	}
#endif
	
	gcube->onUpdate(self.timeSinceLastUpdate);
}

// 描画
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	gcube->onDraw();
}

// 回転方向（over iOS6）
- (NSUInteger)supportedInterfaceOrientations
{
	NSUInteger orient = 0;
#ifdef __GCube_SupportedOrientation_Portrait__
	orient |= UIInterfaceOrientationMaskPortrait;
#endif
#ifdef __GCube_SupportedOrientation_PortraitUpsideDown__
	orient |= UIInterfaceOrientationMaskPortraitUpsideDown;
#endif
#ifdef __GCube_SupportedOrientation_LandscapeLeft__
	orient |= UIInterfaceOrientationMaskLandscapeLeft;
#endif
#ifdef __GCube_SupportedOrientation_LandscapeRight__
	orient |= UIInterfaceOrientationMaskLandscapeRight;
#endif
	return orient;
}

// 回転方向（iOS5）
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
#ifdef __GCube_SupportedOrientation_Portrait__
	if (interfaceOrientation == UIInterfaceOrientationPortrait) return YES;
#endif
#ifdef __GCube_SupportedOrientation_PortraitUpsideDown__
	if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) return YES;
#endif
#ifdef __GCube_SupportedOrientation_LandscapeLeft__
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) return YES;
#endif
#ifdef __GCube_SupportedOrientation_LandscapeRight__
	if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) return YES;
#endif
	return NO;
}

// 画面回転
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	float scale = [UIScreen mainScreen].scale;
	gcube->onSizeChanged(self.view.bounds.size.width*scale, self.view.bounds.size.height*scale, (GCDeviceOrientation)self.interfaceOrientation);
}


#pragma mark - Events

// タッチイベント
- (void)toucheEvent:(NSSet *)touches withEvent:(UIEvent *)event withType:(GCTouchAction)type {
	float scale = [UIScreen mainScreen].scale;
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self.view];
	gcube->onTouch(type, location.x*scale, location.y*scale, touch.timestamp*1000);
}

// タッチ開始イベント
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self toucheEvent:touches withEvent:event withType:GCTouchActionDown];
}

// タッチ移動イベント
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self toucheEvent:touches withEvent:event withType:GCTouchActionMove];
}

// タッチ終了イベント
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self toucheEvent:touches withEvent:event withType:GCTouchActionUp];
}

// タッチキャンセルイベント
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self toucheEvent:touches withEvent:event withType:GCTouchActionCancel];
}



#pragma mark - MotionSensor

// モーションセンサー開始
- (void)startMotionSensor
{
	// インスタンスの生成
	if (!motionMgr) {
		motionMgr = [[CMMotionManager alloc] init];
	}
	
	// 実質、ジャイロスコープの有無を確認
	if (motionMgr.deviceMotionAvailable) {
		// センサーの利用開始
		[motionMgr startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
	}
}

// モーションセンサー停止
- (void)stopMotionSensor
{
	if (motionMgr.deviceMotionActive) {
        [motionMgr stopMagnetometerUpdates];
    }
}

@end
