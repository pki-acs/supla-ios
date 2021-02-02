/*
 Copyright (C) AC SOFTWARE SP. Z O.O.
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SAWizardVC : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btnCancel3;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel2;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnCancel3_width;

@property (weak, nonatomic) IBOutlet UIButton *btnNext3;
@property (weak, nonatomic) IBOutlet UIButton *btnNext2;
@property (weak, nonatomic) IBOutlet UIButton *btnNext1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnNext3_width;

@property (weak, nonatomic) IBOutlet UIView *vPageContent;
@property (nonatomic) BOOL backButtonInsteadOfCancel;
@property (weak, nonatomic) UIView *page;

- (IBAction)nextTouch:(nullable id)sender;
- (IBAction)cancelOrBackTouch:(nullable id)sender;
- (void)backTouch:(nullable id)sender;
- (void)preloaderVisible:(BOOL)visible;
- (void)btnNextEnabled:(BOOL)enabled;
- (void)btnCancelOrBackEnabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
